using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;


public partial class Packaging : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserCode"] == null)
        {
            Response.Redirect("../Login.aspx");
        }
        else
        {
            if (!IsPostBack)
            {
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'Packaging.aspx'";
                        SqlCommand cmds = new SqlCommand(query, cons);
                        cmds.Parameters.AddWithValue("@UserID", username);
                        cons.Open();
                        object result = cmds.ExecuteScalar();
                        if (result == null || result.ToString() != "True")
                        {
                            Response.Redirect("/AccessDenied.aspx");
                        }
                    }
                }
            }
        }
    }

    [WebMethod]
    public static string GetAssignWorkOrders()
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", "PackagingList");
            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static object SaveCompletedQty(int detailedId, decimal completedQty, decimal completedSqFt, decimal revertedSqFt, string mistaken, string faulty, string reason)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                if (mistaken != "False" || faulty != "False")
                {
                    string getssQuery = @"INSERT INTO tbl_MachineReturnQtyLogs(DetailsID,Mistaken,Faulty,reason,CreatedDate,RevertedFrom,RevertedBy)
                                        VALUES(@DetailsID,@Mistaken,@Faulty,@reason,GETDATE(),@RevertedFrom,@RevertedBy)";

                    using (SqlCommand cmd1212 = new SqlCommand(getssQuery, con))
                    {
                        cmd1212.Parameters.AddWithValue("@DetailsID", detailedId);
                        cmd1212.Parameters.AddWithValue("@Mistaken", mistaken);
                        cmd1212.Parameters.AddWithValue("@Faulty", faulty);
                        cmd1212.Parameters.AddWithValue("@reason", reason);
                        cmd1212.Parameters.AddWithValue("@RevertedFrom", "Packaging");
                        cmd1212.Parameters.AddWithValue("@RevertedBy", HttpContext.Current.Session["ID"].ToString());
                        cmd1212.ExecuteNonQuery();
                    }
                }

                int headerId = 0;
                int MachineID = 0;
                int workOrderId = 0;
                int ProductDetailID = 0;
                int PrevSID = 0;
                decimal allocatedQty = 0;
                string headerStatus = "";

                // 1. Get HeaderID + AllocatedQty
                string getQuery = @"
                            SELECT 
                                mpa.ID AS dtlsID,
                                mpa.AllocatedQty,
                                mpa.MachineID,
                                D.HeaderID,
                                D.ID AS ProductDetailID,
                                H.WorkOrderID,
                                mpa.NextStageId
                            FROM tbl_MachineProductionAllocation mpa
                            INNER JOIN tbl_MachineProductionDTLS D
                                ON D.ID = mpa.ProductDtlID
                            INNER JOIN tbl_MachineProductionHDR H
                                ON H.ID = D.HeaderID
                            WHERE mpa.ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(getQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            headerId = Convert.ToInt32(dr["HeaderID"]);
                            MachineID = Convert.ToInt32(dr["MachineID"]);
                            allocatedQty = Convert.ToDecimal(dr["AllocatedQty"]);
                            PrevSID = Convert.ToInt32(dr["NextStageId"]);
                            workOrderId = Convert.ToInt32(dr["WorkOrderID"]);
                            ProductDetailID = Convert.ToInt32(dr["ProductDetailID"]);
                        }
                    }
                }

                // 2. Validation
                if (completedQty > allocatedQty)
                {
                    return new
                    {
                        Status = "Error",
                        Message = "Completed Qty cannot exceed Allocated Qty.",
                        IsCompleted = false
                    };
                }

                bool isCompleted = (completedQty == allocatedQty);

                // 3. Update Detail
                string updateQuery = @"
                UPDATE tbl_MachineProductionAllocation  
                SET PackagingQty = @Stage1CompletedQty
                WHERE ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);
                    cmd.Parameters.AddWithValue("@Stage1CompletedQty", completedQty);

                    cmd.ExecuteNonQuery();
                }

                if (faulty == "True")
                {
                    string updatedQuery = @"
                    UPDATE tbl_MachineProductionAllocation
                    SET PackagingRevertQty = ISNULL(CAST(PackagingRevertQty as decimal),0) + 1 WHERE ID = @DetailedID";

                    using (SqlCommand cmd00 = new SqlCommand(updatedQuery, con))
                    {
                        cmd00.Parameters.AddWithValue("@DetailedID", detailedId);
                        cmd00.ExecuteNonQuery();
                    }


                    string reduceQuery = @"
                        UPDATE tbl_MachineProductionAllocation
                        SET
                            CompletedQty = CASE
                                                WHEN ISNULL(CAST(CompletedQty as decimal),0) > 0
                                                THEN CAST(CompletedQty as decimal) - 1
                                                ELSE 0
                                           END,
                            CompletedSqFeet = CASE
                                                WHEN ISNULL(CAST(CompletedSqFeet as decimal),0) >= @SqFeet
                                                THEN CAST(CompletedSqFeet as decimal) - @SqFeet
                                                ELSE 0
                                              END,
                            CompletedDate = NULL
                        WHERE ID=@Stage1AllocationId";

                    using (SqlCommand cmd = new SqlCommand(reduceQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Stage1AllocationId", detailedId);
                        cmd.Parameters.AddWithValue("@SqFeet", revertedSqFt);
                        cmd.ExecuteNonQuery();
                    }
                    headerStatus = "Reverted";
                }

                return new
                {
                    Status = "Success",
                    Message = "Saved Successfully",
                    IsCompleted = isCompleted,
                    HeaderStatus = headerStatus
                };
            }
        }
        catch (Exception ex)
        {
            return new
            {
                Status = "Error",
                Message = ex.Message,
                IsCompleted = false
            };
        }
    }

    [WebMethod]
    public static object UdpatePackagingStatus(int detailedId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();
                int workOrderId = 0;
                // 1. Get HeaderID + AllocatedQty
                string getQuery = @"
                            SELECT H.WorkOrderID
                            FROM tbl_MachineProductionHDR H
                            WHERE H.ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(getQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            workOrderId = Convert.ToInt32(dr["WorkOrderID"]);
                        }
                    }
                }


                string getssQuery = @"UPDATE MPA
                        SET MPA.PackagingDate = GETDATE()
                        FROM tbl_MachineProductionAllocation MPA
                        INNER JOIN tbl_MachineProductionDTLS MPD
                            ON MPD.ID = MPA.ProductDtlID
                        INNER JOIN tbl_MachineProductionHDR MPH
                            ON MPH.ID = MPD.HeaderID
                        LEFT JOIN tbl_AssignedMachines AM ON AM.MachineId = MPA.MachineID 
                        LEFT JOIN tbl_MachineMaster MM ON AM.MachineId = MM.ID  
                        WHERE MPH.WorkOrderID =@DetailsID";

                using (SqlCommand cmd1212 = new SqlCommand(getssQuery, con))
                {
                    cmd1212.Parameters.AddWithValue("@DetailsID", workOrderId);
                    cmd1212.ExecuteNonQuery();
                }


                string updateHeaderQuery = @"UPDATE tbl_MachineProductionHDR SET PackagingStatus = 'Completed',PackagingFinalDate = GETDATE() 
                    WHERE WorkOrderID =  @DetailedId";

                using (SqlCommand cmupdateHeaderQueryd = new SqlCommand(updateHeaderQuery, con))
                {
                    cmupdateHeaderQueryd.Parameters.AddWithValue("@DetailedId", workOrderId);
                    cmupdateHeaderQueryd.ExecuteNonQuery();
                }

                string updateWOHeaderQuery = @"UPDATE tbl_WorkOrderHdr SET isproductioncompleted = 1 
                    WHERE ID =  @DetailedId";

                using (SqlCommand cmWOHeaderQuery = new SqlCommand(updateWOHeaderQuery, con))
                {
                    cmWOHeaderQuery.Parameters.AddWithValue("@DetailedId", workOrderId);
                    cmWOHeaderQuery.ExecuteNonQuery();
                }


                int PalcOrderId = 0;
                string getStage2 = @"SELECT ISNULL(PlaceOrderID,0) as PlaceOrder FROM tbl_WorkOrderHDR
                           WHERE ID = @WoId ";

                using (SqlCommand cmd = new SqlCommand(getStage2, con))
                {
                    cmd.Parameters.AddWithValue("@WoId", workOrderId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            PalcOrderId = Convert.ToInt32(dr["PlaceOrder"]);
                        }
                    }
                }
                if (PalcOrderId != 0)
                {
                    string querys = @"
                                UPDATE tbl_DealersOrderHDR
                                SET PackagingStatus = @PackagingStatus
                                WHERE ID = @Id";

                    using (SqlCommand cmds = new SqlCommand(querys, con))
                    {
                        cmds.Parameters.AddWithValue("@PackagingStatus", "Order Packed");
                        cmds.Parameters.AddWithValue("@Id", PalcOrderId);

                        cmds.ExecuteNonQuery();
                    }
                }


                con.Close();
                return new
                {
                    Status = "Success",
                };
            }
        }
        catch (Exception ex)
        {
            return new
            {
                Status = "Error",
                Message = ex.Message,
                IsCompleted = false
            };
        }
    }


}



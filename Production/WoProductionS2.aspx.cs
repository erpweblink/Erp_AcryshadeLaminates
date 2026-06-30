using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;


public partial class WoProductionS2 : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WoProductionS2.aspx'";
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
    public static string GetMachines()
    {
        DataTable dt = new DataTable();

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
        using (SqlCommand cmd = new SqlCommand("SELECT ID,MachineName FROM tbl_MachineMaster WHERE AllocatedStage = 'Stage 2'", con))
        {
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static object GetOperatorDetails()
    {
        DataTable dt = new DataTable();
        int username = Convert.ToInt32(HttpContext.Current.Session["ID"].ToString());
        string Role = HttpContext.Current.Session["Role"].ToString();

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Id", username);
            cmd.Parameters.AddWithValue("@WOHeaderId", Role);

            cmd.Parameters.AddWithValue("@SP_Action", "GetOperatorDetailsSs2");
            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }
     
        return new
        {
            Role = HttpContext.Current.Session["Role"].ToString(),
            Data = JsonConvert.SerializeObject(dt)
        };
    }

    [WebMethod]
    public static string GetAssignWorkOrders(int machineId)
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", "AssignWorkOrders");
            cmd.Parameters.AddWithValue("@Id", machineId); // 🔥 ADD THIS
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
                        cmd1212.Parameters.AddWithValue("@RevertedFrom", "Satge 2");
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
                SET
                    CompletedQty = @Stage1CompletedQty,
                    CompletedSqFeet = @Stage1CompetedSqFeet   
                WHERE ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);
                    cmd.Parameters.AddWithValue("@Stage1CompletedQty", completedQty);
                    cmd.Parameters.AddWithValue("@Stage1CompetedSqFeet", completedSqFt);

                    cmd.ExecuteNonQuery();
                }

                if (faulty == "True")
                {
                    string updatedQuery = @"
                    UPDATE tbl_MachineProductionAllocation
                    SET RevertQty = ISNULL(CAST(RevertQty as decimal),0) + 1 WHERE ID = @DetailedID";

                    using (SqlCommand cmd00 = new SqlCommand(updatedQuery, con))
                    {
                        cmd00.Parameters.AddWithValue("@DetailedID", PrevSID);
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
                        cmd.Parameters.AddWithValue("@Stage1AllocationId", PrevSID);
                        cmd.Parameters.AddWithValue("@SqFeet", revertedSqFt);
                        cmd.ExecuteNonQuery();
                    }


                    string updateStage2 = @"
                        UPDATE tbl_MachineProductionAllocation
                        SET
                            AllocatedQty = CASE
                                                WHEN CAST(AllocatedQty as decimal) > 0
                                                THEN CAST(AllocatedQty as decimal) - 1
                                                ELSE 0
                                           END,
                            AllocatedSqFeet = CASE
                                                WHEN CAST(AllocatedSqFeet as decimal) >= @SqFeet
                                                THEN CAST(AllocatedSqFeet as decimal) - @SqFeet
                                                ELSE 0
                                              END                  
                        WHERE ID = @Stage2AllocationId";

                    using (SqlCommand cmd = new SqlCommand(updateStage2, con))
                    {
                        cmd.Parameters.AddWithValue("@Stage2AllocationId", detailedId);
                        cmd.Parameters.AddWithValue("@SqFeet", revertedSqFt); 
                        cmd.ExecuteNonQuery();
                    }

                    headerStatus = "Reduced";
                }

                // 4.To Update Header Status
                int TotatQty = 0, CompletedssQty = 0;

                string getTotatQtyQuery = @"SELECT SUM(CAST(TotalQty as decimal)) as TotalQty
                        FROM tbl_MachineProductionDTLS MPD
                        LEFT JOIN tbl_MachineProductionHDR MPH ON MPH.ID = MPD.HeaderID 
                        WHERE MPH.WorkOrderID = @DetailedId";

                using (SqlCommand cmdTotatQty = new SqlCommand(getTotatQtyQuery, con))
                {
                    cmdTotatQty.Parameters.AddWithValue("@DetailedId", workOrderId);

                    object result = cmdTotatQty.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        TotatQty = Convert.ToInt32(result);
                    }
                }

                string getCompletedQtyQuery = @"SELECT SUM(CAST(CompletedQty as decimal)) as CompletedQty
                            FROM tbl_MachineProductionAllocation MPA
                            LEFT JOIN tbl_MachineProductionDTLS MPD ON MPD.ID = MPA.ProductDtlID
                            LEFT JOIN tbl_MachineProductionHDR MPH ON  MPH.ID = MPD.HeaderID
                            LEFT JOIN tbl_AssignedMachines AM ON AM.MachineId = MPA.MachineID 
                            LEFT JOIN tbl_MachineMaster MM ON AM.MachineId = MM.ID   
                            WHERE  MM.AllocatedStage = 'Stage 2' AND MPH.WorkOrderID = @DetailedId";

                using (SqlCommand cmdCompletedQty = new SqlCommand(getCompletedQtyQuery, con))
                {
                    cmdCompletedQty.Parameters.AddWithValue("@DetailedId", workOrderId);

                    object result = cmdCompletedQty.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        CompletedssQty = Convert.ToInt32(result);
                    }
                }

                if (TotatQty == CompletedssQty)
                {
                    string updateHeaderQuery = @"UPDATE tbl_MachineProductionHDR SET S2Status = 'Completed' 
                    WHERE WorkOrderID =  @DetailedId";

                    using (SqlCommand cmupdateHeaderQueryd = new SqlCommand(updateHeaderQuery, con))
                    {
                        cmupdateHeaderQueryd.Parameters.AddWithValue("@DetailedId", workOrderId);
                        cmupdateHeaderQueryd.ExecuteNonQuery();
                    }


                    string updateDateQuery = @" UPDATE MPA
                        SET MPA.CompletedDate = GETDATE()
                        FROM tbl_MachineProductionAllocation MPA
                        INNER JOIN tbl_MachineProductionDTLS MPD
                            ON MPD.ID = MPA.ProductDtlID
                        INNER JOIN tbl_MachineProductionHDR MPH
                            ON MPH.ID = MPD.HeaderID
                        LEFT JOIN tbl_AssignedMachines AM ON AM.MachineId = MPA.MachineID 
                        LEFT JOIN tbl_MachineMaster MM ON AM.MachineId = MM.ID  
                        WHERE MPH.WorkOrderID = @DetailedID AND MM.AllocatedStage = 'Stage 2'";

                    using (SqlCommand cmd = new SqlCommand(updateDateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@DetailedID", workOrderId);
                        cmd.ExecuteNonQuery();
                    }

                    headerStatus = "Completed";
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

}



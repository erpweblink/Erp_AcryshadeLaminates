using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Web;
using System.Web.Services;


public partial class WoProductionS1 : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WoProductionS1.aspx'";
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
        using (SqlCommand cmd = new SqlCommand("SELECT ID,MachineName FROM tbl_MachineMaster WHERE AllocatedStage = 'Stage 1'", con))
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
            cmd.Parameters.AddWithValue("@SP_Action", "GetOperatorDetailsS1");
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
    public static object SaveCompletedQty(int detailedId, decimal completedQty, decimal completedSqFt)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                int headerId = 0;
                int workOrderId = 0;
                int ProductDetailID = 0;
                decimal allocatedQty = 0;
                int stage2MachineId = 0;
                int machineId = 0;

                #region Get Header Info

                string getQuery = @"
                            SELECT 
                                mpa.ID AS dtlsID,
                                mpa.AllocatedQty,
                                mpa.MachineID,
                                D.HeaderID,
                                D.ID AS ProductDetailID,
                                H.WorkOrderID
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
                            allocatedQty = Convert.ToDecimal(dr["AllocatedQty"]);
                            ProductDetailID = Convert.ToInt32(dr["ProductDetailID"]);
                            workOrderId = Convert.ToInt32(dr["WorkOrderID"]);
                            machineId = Convert.ToInt32(dr["MachineID"]);
                        }
                    }
                }

                #endregion

                #region Validation

                if (completedQty > allocatedQty)
                {
                    return new
                    {
                        Status = "Error",
                        Message = "Completed Qty cannot exceed Allocated Qty.",
                        IsCompleted = false
                    };
                }

                bool allocationCompleted = (completedQty == allocatedQty);

                #endregion


                decimal oldCompletedQty = 0;
                decimal oldCompletedSqFt = 0;

                string oldQuery = @"SELECT
                                        ISNULL(CompletedQty,0) AS CompletedQty,
                                        ISNULL(CompletedSqFeet,0) AS CompletedSqFeet
                                    FROM tbl_MachineProductionAllocation
                                    WHERE ID=@DetailedID";

                using (SqlCommand cmdOld = new SqlCommand(oldQuery, con))
                {
                    cmdOld.Parameters.AddWithValue("@DetailedID", detailedId);

                    using (SqlDataReader dr = cmdOld.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            oldCompletedQty = Convert.ToDecimal(dr["CompletedQty"]);
                            oldCompletedSqFt = Convert.ToDecimal(dr["CompletedSqFeet"]);
                        }
                    }
                }


                #region Update Detail (Stage 1)

                string updateQuery = @"
                    UPDATE tbl_MachineProductionAllocation
                    SET
                        CompletedQty = @Stage1CompletedQty,
                        CompletedSqFeet = @Stage1CompetedSqFeet,
                        CompletedDate =
                            CASE
                                WHEN @Stage1CompletedQty =
                                     TRY_CONVERT(decimal(18,2), AllocatedQty)
                                     AND CompletedDate IS NULL
                                THEN GETDATE()
                                ELSE CompletedDate
                            END
                    WHERE ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);
                    cmd.Parameters.AddWithValue("@Stage1CompletedQty", completedQty);
                    cmd.Parameters.AddWithValue("@Stage1CompetedSqFeet", completedSqFt);

                    cmd.ExecuteNonQuery();
                }

                #endregion

                // To Set Machin ID
                decimal requiredQty = allocatedQty;

                string machineQuery = @"
                    SELECT TOP 1
                        M.ID as MachineID,
                        ((TRY_CAST(M.MachinePerHRQty AS FLOAT) * TRY_CAST(M.MachineRunningHR AS FLOAT))
                         - (ISNULL(SUM(TRY_CAST(MPD.AllocatedSqFeet AS FLOAT)), 0)
                         - ISNULL(SUM(TRY_CAST(MPD.Stage1CompetedSqFeet AS FLOAT)), 0))
                        ) AS MachineAvailable
                    FROM tbl_MachineMaster M
                    LEFT JOIN tbl_MachineProductionDTLS MPD 
                        ON MPD.Stage1MachineID = M.ID
                    WHERE M.IsDeleted = 0
                      AND M.IsActive = 1
                      AND M.AllocatedStage = 'Stage 2'
                    GROUP BY M.ID, M.MachinePerHRQty, M.MachineRunningHR
                    HAVING
                        ((TRY_CAST(M.MachinePerHRQty AS FLOAT) * TRY_CAST(M.MachineRunningHR AS FLOAT))
                         - (ISNULL(SUM(TRY_CAST(MPD.AllocatedSqFeet AS FLOAT)), 0)
                         - ISNULL(SUM(TRY_CAST(MPD.Stage1CompetedSqFeet AS FLOAT)), 0))
                        ) >= @RequiredQty
                    ORDER BY MachineAvailable DESC";

                using (SqlCommand cmds = new SqlCommand(machineQuery, con))
                {
                    cmds.Parameters.AddWithValue("@RequiredQty", requiredQty);

                    object result = cmds.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        stage2MachineId = Convert.ToInt32(result);
                    }
                }

                if (stage2MachineId > 0)
                {
                    string GETMCQuery = @"SELECT ID
                                    FROM tbl_MachineProductionAllocation
                                    WHERE ProductDtlID = @ProductDtlID
                                    AND MachineID = @Stage2MachineID
                                    AND NextStageId IS NOT NULL";
                    using (SqlCommand cmdsss = new SqlCommand(GETMCQuery, con))
                    {
                        cmdsss.Parameters.AddWithValue("@ProductDtlID", ProductDetailID);
                        cmdsss.Parameters.AddWithValue("@Stage2MachineID", stage2MachineId);

                        object res = cmdsss.ExecuteScalar();
                        string stag2id = res == null || res == DBNull.Value ? "0" : res.ToString();

                        string produId = null, AllocatedQty = null, AllocatedSqFeet = null;
                        string getProd = @"SELECT ProductDtlID, ISNULL(AllocatedQty,0) AS CompletedQty,
                                            ISNULL(AllocatedSqFeet,0) AS CompletedSqFeet FROM tbl_MachineProductionAllocation 
                                                  WHERE ID = @DetailedID";

                        using (SqlCommand cmd1 = new SqlCommand(getProd, con))
                        {
                            cmd1.Parameters.AddWithValue("@DetailedID", stag2id == "0" ? detailedId.ToString() : stag2id);

                            using (SqlDataReader dr1 = cmd1.ExecuteReader())
                            {
                                if (dr1.Read())
                                {
                                    produId = dr1["ProductDtlID"].ToString();
                                    AllocatedQty = dr1["CompletedQty"].ToString();
                                    AllocatedSqFeet = dr1["CompletedSqFeet"].ToString();
                                }
                            }
                        }

                        if (res == null || res == DBNull.Value)
                        {

                            string assignQuery = @"INSERT INTO tbl_MachineProductionAllocation(ProductDtlID,MachineID,AllocatedQty,AllocatedSqFeet,NextStageId)
                                          VALUES(@ProductDtlID,@MachineID,@AllocatedQty,@AllocatedSqFeet,@DetailedID)";

                            using (SqlCommand cmdss = new SqlCommand(assignQuery, con))
                            {
                                cmdss.Parameters.AddWithValue("@MachineID", stage2MachineId);
                                cmdss.Parameters.AddWithValue("@DetailedID", detailedId);
                                cmdss.Parameters.AddWithValue("@ProductDtlID", produId);
                                cmdss.Parameters.AddWithValue("@AllocatedQty", completedQty);
                                cmdss.Parameters.AddWithValue("@AllocatedSqFeet", completedSqFt);

                                cmdss.ExecuteNonQuery();
                            }
                        }
                        else
                        {

                           
                            string updatesQuery = @"
                                        UPDATE tbl_MachineProductionAllocation
                                        SET AllocatedQty = @Stage1CompletedQty,
                                            AllocatedSqFeet = @Stage1CompetedSqFeet
                                        WHERE ID = @DetailedID";

                            using (SqlCommand cmd2 = new SqlCommand(updatesQuery, con))
                            {
                                decimal existingQty = Convert.ToDecimal(AllocatedQty);
                                decimal existingSqFt = Convert.ToDecimal(AllocatedSqFeet);

                                decimal qtyToTransfer = completedQty - oldCompletedQty;
                                decimal sqFtToTransfer = completedSqFt - oldCompletedSqFt;

                                decimal newQty = existingQty + qtyToTransfer;
                                decimal newSqFt = existingSqFt + sqFtToTransfer;

                                cmd2.Parameters.AddWithValue("@DetailedID", stag2id);
                                cmd2.Parameters.AddWithValue("@Stage1CompletedQty", newQty);
                                cmd2.Parameters.AddWithValue("@Stage1CompetedSqFeet", newSqFt);

                                cmd2.ExecuteNonQuery();
                            }
                        }
                    }
                }

                decimal totalAllocated = 0;
                decimal totalCompleted = 0;

                string statusQuery = @"
                            SELECT
                                ISNULL(SUM(CAST(A.AllocatedQty as decimal)),0) AS AllocQty,
                                ISNULL(SUM(CAST(A.CompletedQty as decimal)),0) AS CompletedQty
                            FROM tbl_MachineProductionAllocation A
                            INNER JOIN tbl_MachineProductionDTLS D
                                ON D.ID = A.ProductDtlID
                            WHERE D.HeaderID = @HeaderID
                            AND A.MachineID = @MachineID";
                using (SqlCommand cmd2 = new SqlCommand(statusQuery, con))
                {
                    cmd2.Parameters.AddWithValue("@HeaderID", headerId);
                    cmd2.Parameters.AddWithValue("@MachineID", machineId);

                    using (SqlDataReader dr2 = cmd2.ExecuteReader())
                    {
                        if (dr2.Read())
                        {
                            totalAllocated = Convert.ToDecimal(dr2["AllocQty"]);
                            totalCompleted = Convert.ToDecimal(dr2["CompletedQty"]);
                        }
                    }
                }
                string headerStatus = "Machine Allocated";

                if (totalCompleted == 0)
                {
                    headerStatus = "Machine Allocated";
                }
                else if (totalCompleted < totalAllocated)
                {
                    headerStatus = "Work Started";
                }
                else
                {
                    headerStatus = "Completed";
                }

                return new
                {
                    Status = "Success",
                    Message = "Saved Successfully",
                    IsCompleted = allocationCompleted,
                    HeaderStatus = headerStatus,
                    Stage2MachineID = stage2MachineId
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



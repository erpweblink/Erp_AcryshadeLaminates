using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WoProduction.aspx'";
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
            cmd.Parameters.AddWithValue("@SP_Action", "AssignWorkOrderS1");
            cmd.Parameters.AddWithValue("@Id", machineId); // 🔥 ADD THIS
            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return JsonConvert.SerializeObject(dt);
    }

    // [WebMethod]
    //public static object SaveCompletedQty(int detailedId, decimal completedQty, decimal completedSqFt)
    //{
    //    try
    //    {
    //        using (SqlConnection con = new SqlConnection(
    //            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
    //        {
    //            con.Open();

    //            int headerId = 0;
    //            decimal allocatedQty = 0;

    //            // 1. Get HeaderID + AllocatedQty
    //            string getQuery = @"
    //            SELECT HeaderID, AllocatedQty
    //            FROM tbl_MachineProductionDTLS
    //            WHERE ID = @DetailedID";

    //            using (SqlCommand cmd = new SqlCommand(getQuery, con))
    //            {
    //                cmd.Parameters.AddWithValue("@DetailedID", detailedId);

    //                using (SqlDataReader dr = cmd.ExecuteReader())
    //                {
    //                    if (dr.Read())
    //                    {
    //                        headerId = Convert.ToInt32(dr["HeaderID"]);
    //                        allocatedQty = Convert.ToDecimal(dr["AllocatedQty"]);
    //                    }
    //                }
    //            }

    //            // 2. Validation
    //            if (completedQty > allocatedQty)
    //            {
    //                return new
    //                {
    //                    Status = "Error",
    //                    Message = "Completed Qty cannot exceed Allocated Qty.",
    //                    IsCompleted = false
    //                };
    //            }

    //            bool isCompleted = (completedQty == allocatedQty);

    //            // 3. Update Detail
    //            string updateQuery = @"
    //            UPDATE tbl_MachineProductionDTLS
    //            SET
    //                Stage1CompletedQty = @Stage1CompletedQty,
    //                Stage1CompetedSqFeet = @Stage1CompetedSqFeet,
    //                Stage1CompletedDate =
    //                    CASE
    //                        WHEN @Stage1CompletedQty =
    //                             TRY_CONVERT(decimal(18,2), AllocatedQty)
    //                             AND Stage1CompletedDate IS NULL
    //                        THEN GETDATE()
    //                        ELSE Stage1CompletedDate
    //                    END
    //            WHERE ID = @DetailedID";

    //            using (SqlCommand cmd = new SqlCommand(updateQuery, con))
    //            {
    //                cmd.Parameters.AddWithValue("@DetailedID", detailedId);
    //                cmd.Parameters.AddWithValue("@Stage1CompletedQty", completedQty);
    //                cmd.Parameters.AddWithValue("@Stage1CompetedSqFeet", completedSqFt);

    //                cmd.ExecuteNonQuery();
    //            }

    //            // 4. HEADER STATUS LOGIC
    //            string headerStatus = "Machine Allocated";

    //            // Check if ANY work started
    //            string startedQuery = @"
    //            SELECT COUNT(*)
    //            FROM tbl_MachineProductionDTLS
    //            WHERE HeaderID = @HeaderID
    //            AND Stage1CompletedQty > 0";

    //            using (SqlCommand cmd = new SqlCommand(startedQuery, con))
    //            {
    //                cmd.Parameters.AddWithValue("@HeaderID", headerId);

    //                int startedCount = (int)cmd.ExecuteScalar();

    //                if (startedCount > 0)
    //                    headerStatus = "Work Started";
    //            }

    //            // Check if ALL completed
    //            string completedQuery = @"
    //            SELECT COUNT(*)
    //            FROM tbl_MachineProductionDTLS
    //            WHERE HeaderID = @HeaderID
    //            AND Stage1CompletedDate IS NULL";

    //            using (SqlCommand cmd = new SqlCommand(completedQuery, con))
    //            {
    //                cmd.Parameters.AddWithValue("@HeaderID", headerId);

    //                int pendingCount = (int)cmd.ExecuteScalar();

    //                if (pendingCount == 0)
    //                    headerStatus = "Completed";
    //            }

    //            // 5. UPDATE HEADER
    //            string updateHeader = @"
    //            UPDATE tbl_MachineProductionHDR
    //            SET Status = @Status
    //            WHERE ID = @HeaderID";

    //            using (SqlCommand cmd = new SqlCommand(updateHeader, con))
    //            {
    //                cmd.Parameters.AddWithValue("@Status", headerStatus);
    //                cmd.Parameters.AddWithValue("@HeaderID", headerId);

    //                cmd.ExecuteNonQuery();
    //            }

    //            return new
    //            {
    //                Status = "Success",
    //                Message = "Saved Successfully",
    //                IsCompleted = isCompleted,
    //                HeaderStatus = headerStatus
    //            };
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        return new
    //        {
    //            Status = "Error",
    //            Message = ex.Message,
    //            IsCompleted = false
    //        };
    //    }
    //}


    [WebMethod]
    public static object SaveCompletedQty(int detailedId, decimal completedQty, decimal completedSqFt)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                int headerId = 0;
                int workOrderId = 0;
                decimal allocatedQty = 0;

                int stage2MachineId = 0;

                #region Get Header Info

                string getQuery = @"
                SELECT
                    D.HeaderID,
                    D.AllocatedQty,
                    H.WorkOrderID
                FROM tbl_MachineProductionDTLS D
                INNER JOIN tbl_MachineProductionHDR H
                    ON H.ID = D.HeaderID
                WHERE D.ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(getQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            headerId = Convert.ToInt32(dr["HeaderID"]);
                            allocatedQty = Convert.ToDecimal(dr["AllocatedQty"]);
                            workOrderId = Convert.ToInt32(dr["WorkOrderID"]);
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

                #region Update Detail (Stage 1)

                string updateQuery = @"
                UPDATE tbl_MachineProductionDTLS
                SET
                    Stage1CompletedQty = @Stage1CompletedQty,
                    Stage1CompetedSqFeet = @Stage1CompetedSqFeet,
                    Stage1CompletedDate =
                        CASE
                            WHEN @Stage1CompletedQty =
                                 TRY_CONVERT(decimal(18,2), AllocatedQty)
                                 AND Stage1CompletedDate IS NULL
                            THEN GETDATE()
                            ELSE Stage1CompletedDate
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

                string headerStatus = "Machine Allocated";

                #region Work Started Check

                string startedQuery = @"
                SELECT COUNT(*)
                FROM tbl_MachineProductionDTLS
                WHERE HeaderID = @HeaderID
                AND ISNULL(CAST(Stage1CompletedQty as decimal),0) > 0";

                using (SqlCommand cmd = new SqlCommand(startedQuery, con))
                {
                    cmd.Parameters.AddWithValue("@HeaderID", headerId);

                    int startedCount = Convert.ToInt32(cmd.ExecuteScalar());

                    if (startedCount > 0)
                        headerStatus = "Work Started";
                }

                #endregion

                #region Allocation Completed Check

                string pendingAllocationQuery = @"
                SELECT COUNT(*)
                FROM tbl_MachineProductionDTLS
                WHERE HeaderID = @HeaderID
                AND (
                        Stage1CompletedQty IS NULL
                        OR Stage1CompletedQty < AllocatedQty
                    )";

                using (SqlCommand cmd = new SqlCommand(pendingAllocationQuery, con))
                {
                    cmd.Parameters.AddWithValue("@HeaderID", headerId);

                    int pendingCount = Convert.ToInt32(cmd.ExecuteScalar());

                    if (pendingCount == 0)
                        headerStatus = "Partially Completed";
                }

                #endregion

                #region Work Order Completion Check

                decimal originalQty = 0;
                decimal totalCompletedQty = 0;

                string woQuery = @"
                SELECT SUM(ISNULL(CAST(Qty as decimal),0))
                FROM tbl_WorkOrderDetails
                WHERE HeaderID = @WorkOrderID";

                using (SqlCommand cmd = new SqlCommand(woQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", workOrderId);

                    object obj = cmd.ExecuteScalar();
                    originalQty = obj == DBNull.Value ? 0 : Convert.ToDecimal(obj);
                }

                string completedQuery = @"
                SELECT SUM(ISNULL(CAST(Stage1CompletedQty as decimal),0))
                FROM tbl_MachineProductionDTLS D
                INNER JOIN tbl_MachineProductionHDR H
                    ON H.ID = D.HeaderID
                WHERE H.WorkOrderID = @WorkOrderID";

                using (SqlCommand cmd = new SqlCommand(completedQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", workOrderId);

                    object obj = cmd.ExecuteScalar();
                    totalCompletedQty = obj == DBNull.Value ? 0 : Convert.ToDecimal(obj);
                }

                if (totalCompletedQty >= originalQty && originalQty > 0)
                {
                    headerStatus = "Completed";
                }

                #endregion

                #region STAGE 2 MACHINE ALLOCATION (NEW LOGIC)

                if (headerStatus == "Completed")
                {
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

                    using (SqlCommand cmd = new SqlCommand(machineQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@RequiredQty", requiredQty);

                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            stage2MachineId = Convert.ToInt32(result);
                        }
                    }

                    if (stage2MachineId > 0)
                    {
                        string assignQuery = @"
                        UPDATE tbl_MachineProductionDTLS
                        SET Stage2MachineID = @MachineID,Stage2CompletedQty = '0',Stage2CompetedSqFeet ='0'
                        WHERE HeaderID = @DetailedID";

                        using (SqlCommand cmd = new SqlCommand(assignQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@MachineID", stage2MachineId);
                            cmd.Parameters.AddWithValue("@DetailedID", headerId);

                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                #endregion

                #region Update Header Status

                string updateHeader = @"
                UPDATE tbl_MachineProductionHDR
                SET Status = @Status
                WHERE ID = @HeaderID";

                using (SqlCommand cmd = new SqlCommand(updateHeader, con))
                {
                    cmd.Parameters.AddWithValue("@Status", headerStatus);
                    cmd.Parameters.AddWithValue("@HeaderID", headerId);

                    cmd.ExecuteNonQuery();
                }

                #endregion

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



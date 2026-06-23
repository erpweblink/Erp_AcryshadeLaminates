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

            cmd.Parameters.AddWithValue("@SP_Action", "GetOperatorDetailsS2");
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
            cmd.Parameters.AddWithValue("@SP_Action", "AssignWorkOrderS2");
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
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                int headerId = 0;
                decimal allocatedQty = 0;
                string headerStatus = "";

                // 1. Get HeaderID + AllocatedQty
                string getQuery = @"
                SELECT HeaderID, AllocatedQty
                FROM tbl_MachineProductionDTLS
                WHERE ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(getQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            headerId = Convert.ToInt32(dr["HeaderID"]);
                            allocatedQty = Convert.ToDecimal(dr["AllocatedQty"]);
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
                UPDATE tbl_MachineProductionDTLS
                SET
                    Stage2CompletedQty = @Stage1CompletedQty,
                    Stage2CompetedSqFeet = @Stage1CompetedSqFeet,
                    Stage2CompletedDate =
                        CASE
                            WHEN @Stage1CompletedQty =
                                 TRY_CONVERT(decimal(18,2), AllocatedQty)
                                 AND Stage2CompletedDate IS NULL
                            THEN GETDATE()
                            ELSE Stage2CompletedDate
                        END
                WHERE ID = @DetailedID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DetailedID", detailedId);
                    cmd.Parameters.AddWithValue("@Stage1CompletedQty", completedQty);
                    cmd.Parameters.AddWithValue("@Stage1CompetedSqFeet", completedSqFt);

                    cmd.ExecuteNonQuery();
                }

                //.Check For Complettion 
                #region Work Order Completion Check

                decimal originalQty = 0;
                decimal totalCompletedQty = 0;

                string woQuery = @"
                SELECT SUM(ISNULL(CAST(TotalQty as decimal),0))
                FROM tbl_MachineProductionDTLS
                WHERE HeaderID = @WorkOrderID";

                using (SqlCommand cmd = new SqlCommand(woQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", headerId);

                    object obj = cmd.ExecuteScalar();
                    originalQty = obj == DBNull.Value ? 0 : Convert.ToDecimal(obj);
                }

                string completedQuery = @"
                SELECT SUM(ISNULL(CAST(Stage2CompletedQty as decimal),0))
                FROM tbl_MachineProductionDTLS 
                WHERE HeaderID = @WorkOrderID";

                using (SqlCommand cmd = new SqlCommand(completedQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", headerId);

                    object obj = cmd.ExecuteScalar();
                    totalCompletedQty = obj == DBNull.Value ? 0 : Convert.ToDecimal(obj);
                }

                if (totalCompletedQty >= originalQty && originalQty > 0)
                {
                    headerStatus = "Completed";
                    string updateHeader = @"
                        UPDATE tbl_MachineProductionHDR
                        SET S2Status = @Status
                        WHERE ID = @HeaderID";

                    using (SqlCommand cmd = new SqlCommand(updateHeader, con))
                    {
                        cmd.Parameters.AddWithValue("@Status", headerStatus);
                        cmd.Parameters.AddWithValue("@HeaderID", headerId);

                        cmd.ExecuteNonQuery();
                    }

                }

                #endregion


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



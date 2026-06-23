using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Services;


public partial class AssignWorkOrder : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);

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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'AssignWorkOrder.aspx'";
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

                lblDate.InnerText = DateTime.Now.Date.ToString("dd-MM-yyyy");
                txtdate.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }
    }


    [WebMethod]
    public static string GetMachineDetails()
    {
        DataTable dt = new DataTable();

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", "GetMachineCapacity");
            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static string GetWorkOrders()
    {
        DataTable dt = new DataTable();

        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", "GetWorkOrder");
            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static decimal GetScheduledQtyByDate(string scheduleDate)
    {
        decimal totalSqFt = 0;

        try
        {
            DateTime date = DateTime.Parse(scheduleDate);

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                string query = @"
                SELECT SUM(CAST(ISNULL(dtls.SqFeet,0) as decimal)) as Sqfeet, hdr.ScheduledDate as ScheduledDate
                 FROM tbl_WorkOrderDetails dtls  
                 LEFT JOIN  tbl_WorkOrderHDR hdr ON hdr.ID = dtls.Headerid
                 WHERE hdr.isdesignapproved = 1 AND hdr.IsDeleted = 0 AND ScheduledDate = @ScheduleDate
                 GROUP BY  ScheduledDate ";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ScheduleDate", date.Date);

                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        totalSqFt = Convert.ToDecimal(result);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // log error if needed
            throw new Exception("Error fetching scheduled quantity: " + ex.Message);
        }

        return totalSqFt;
    }

    [WebMethod]
    public static string SetScheduledDates(object[] list)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                foreach (var item in list)
                {
                    var dict = item as Dictionary<string, object>;

                    int woId = Convert.ToInt32(dict["woId"]);
                    string scheduleDate = dict["scheduleDate"].ToString();

                    string query = @"
                    UPDATE tbl_WorkOrderHDR
                    SET ScheduledDate = @ScheduledDate
                    WHERE ID = @WoId";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@ScheduledDate", scheduleDate);
                        cmd.Parameters.AddWithValue("@WoId", woId);

                        cmd.ExecuteNonQuery();
                    }
                }
            }

            return "Success";
        }
        catch (Exception ex)
        {
            return "Error: " + ex.Message;
        }
    }

    //[WebMethod]
    //public static string SaveMachineAllocation(object[] allocations)
    //{
    //    try
    //    {
    //        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
    //        {
    //            con.Open();

    //            foreach (Dictionary<string, object> allocation in allocations)
    //            {
    //                int woId = Convert.ToInt32(allocation["woId"]);
    //                string woNo = allocation["woNo"].ToString();

    //                int machineId = Convert.ToInt32(allocation["machineId"]);
    //                string machineName = allocation["machineName"].ToString();

    //                DateTime dt = Convert.ToDateTime(allocation["AssignedDate"].ToString());
    //                decimal totalQty = Convert.ToDecimal(allocation["totalQty"]);

    //                int Id = 0;
    //                using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
    //                {
    //                    cmd.CommandType = CommandType.StoredProcedure;

    //                    // MASTER DATA
    //                    cmd.Parameters.AddWithValue("@WOHeaderId", woId);
    //                    cmd.Parameters.AddWithValue("@WorkOrderNo", woNo);
    //                    cmd.Parameters.AddWithValue("@sheduledate", dt);
    //                    cmd.Parameters.AddWithValue("@SP_Action", "InsertToProductionHdr");
    //                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
    //                    cmd.ExecuteNonQuery();
    //                    Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);
    //                }

    //               // Get Details
    //                object[] details = allocation["details"] as object[];

    //                if (details != null)
    //                {
    //                    foreach (Dictionary<string, object> detail in details)
    //                    {
    //                        int detailedId = Convert.ToInt32(detail["detailedId"]);
    //                        string product = detail["product"].ToString();
    //                        string partNo = detail["partNo"].ToString();
    //                        string size = detail["size"].ToString();
    //                        string sqFeet = detail["sqFeet"].ToString();

    //                        decimal qty = Convert.ToDecimal(detail["qty"]);
    //                        decimal usedQty = Convert.ToDecimal(detail["usedQty"]);
    //                        decimal usedSqFt = Convert.ToDecimal(detail["usedSqFt"]);

    //                        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
    //                        {
    //                            cmd.CommandType = CommandType.StoredProcedure;

    //                            // MASTER DATA
    //                            cmd.Parameters.AddWithValue("@HeaderID", Id);
    //                            cmd.Parameters.AddWithValue("@ProductName", product);
    //                            cmd.Parameters.AddWithValue("@Size", size);
    //                            cmd.Parameters.AddWithValue("@TotalQty", qty);
    //                            cmd.Parameters.AddWithValue("@SqFeet", sqFeet);
    //                            cmd.Parameters.AddWithValue("@AllocatedQty", usedQty);
    //                            cmd.Parameters.AddWithValue("@AllocatedSqFeet", usedSqFt);
    //                            cmd.Parameters.AddWithValue("@Stage1MachineID", machineId);
    //                            cmd.Parameters.AddWithValue("@SP_Action", "InsertToProductionDtls");
    //                            cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
    //                            cmd.ExecuteNonQuery();
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        return "Success";
    //    }
    //    catch (Exception ex)
    //    {
    //        return ex.ToString();
    //    }
    //}

    [WebMethod]
    public static string SaveMachineAllocation(object[] allocations)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                foreach (Dictionary<string, object> allocation in allocations)
                {
                    int woId = Convert.ToInt32(allocation["woId"]);
                    string woNo = allocation["woNo"].ToString();

                    int machineId = Convert.ToInt32(allocation["machineId"]);
                    DateTime assignedDate =
                        Convert.ToDateTime(allocation["AssignedDate"]);

                    int productionHeaderId = 0;

                    #region CHECK EXISTING HEADER

                    string checkHeaderQuery = @"
                SELECT TOP 1 ID
                FROM tbl_MachineProductionHDR
                WHERE WorkOrderID = @WorkOrderID
                  AND S1Status <> 'Completed'
                ORDER BY ID DESC";

                    using (SqlCommand cmd = new SqlCommand(checkHeaderQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@WorkOrderID", woId);

                        object obj = cmd.ExecuteScalar();

                        if (obj != null)
                            productionHeaderId = Convert.ToInt32(obj);
                    }

                    #endregion

                    #region CREATE HEADER IF NOT EXISTS

                    if (productionHeaderId == 0)
                    {
                        using (SqlCommand cmd =
                            new SqlCommand("SP_ProductionsPlanning", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.AddWithValue("@WOHeaderId", woId);
                            cmd.Parameters.AddWithValue("@WorkOrderNo", woNo);
                            cmd.Parameters.AddWithValue("@sheduledate", assignedDate);
                            cmd.Parameters.AddWithValue("@SP_Action",
                                "InsertToProductionHdr");

                            cmd.Parameters.Add("@Result", SqlDbType.Int)
                                .Direction = ParameterDirection.Output;

                            cmd.ExecuteNonQuery();

                            productionHeaderId =
                                Convert.ToInt32(cmd.Parameters["@Result"].Value);
                        }
                    }

                    #endregion

                    object[] details = allocation["details"] as object[];

                    if (details == null)
                        continue;

                    foreach (Dictionary<string, object> detail in details)
                    {
                        decimal usedQty =
                            Convert.ToDecimal(detail["usedQty"]);

                        decimal usedSqFt =
                            Convert.ToDecimal(detail["usedSqFt"]);

                        // skip rows with no allocation
                        if (usedQty <= 0)
                            continue;

                        string product =
                            Convert.ToString(detail["product"]);

                        string size =
                            Convert.ToString(detail["size"]);

                        decimal qty =
                            Convert.ToDecimal(detail["qty"]);

                        decimal sqFeet =
                            Convert.ToDecimal(detail["sqFeet"]);

                        int existingDetailId = 0;

                        #region CHECK EXISTING DETAIL

                        string checkDetailQuery = @"
                    SELECT TOP 1 ID
                    FROM tbl_MachineProductionDTLS
                    WHERE HeaderID = @HeaderID
                      AND ProductName = @ProductName
                      AND Size = @Size";

                        using (SqlCommand cmd =
                            new SqlCommand(checkDetailQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@HeaderID",
                                productionHeaderId);

                            cmd.Parameters.AddWithValue("@ProductName",
                                product);

                            cmd.Parameters.AddWithValue("@Size",
                                size);

                            object obj = cmd.ExecuteScalar();

                            if (obj != null)
                                existingDetailId =
                                    Convert.ToInt32(obj);
                        }

                        #endregion

                        #region UPDATE EXISTING DETAIL

                        if (existingDetailId > 0)
                        {
                            string updateQuery = @"
                        UPDATE tbl_MachineProductionDTLS
                        SET
                            AllocatedQty =
                                ISNULL(CAST(AllocatedQty as decimal),0) + @AllocatedQty,

                            AllocatedSqFeet =
                                ISNULL(CAST(AllocatedSqFeet as decimal),0) + @AllocatedSqFeet
                        WHERE ID = @ID";

                            using (SqlCommand cmd =
                                new SqlCommand(updateQuery, con))
                            {
                                cmd.Parameters.AddWithValue("@ID",
                                    existingDetailId);

                                cmd.Parameters.AddWithValue("@AllocatedQty",
                                    usedQty);

                                cmd.Parameters.AddWithValue("@AllocatedSqFeet",
                                    usedSqFt);

                                cmd.ExecuteNonQuery();
                            }
                        }

                        #endregion

                        #region INSERT NEW DETAIL

                        else
                        {
                            using (SqlCommand cmd =
                                new SqlCommand("SP_ProductionsPlanning", con))
                            {
                                cmd.CommandType =
                                    CommandType.StoredProcedure;

                                cmd.Parameters.AddWithValue("@HeaderID",
                                    productionHeaderId);

                                cmd.Parameters.AddWithValue("@ProductName",
                                    product);

                                cmd.Parameters.AddWithValue("@Size",
                                    size);

                                cmd.Parameters.AddWithValue("@TotalQty",
                                    qty);

                                cmd.Parameters.AddWithValue("@SqFeet",
                                    sqFeet);

                                cmd.Parameters.AddWithValue("@AllocatedQty",
                                    usedQty);

                                cmd.Parameters.AddWithValue("@AllocatedSqFeet",
                                    usedSqFt);

                                cmd.Parameters.AddWithValue("@Stage1MachineID",
                                    machineId);

                                cmd.Parameters.AddWithValue("@SP_Action",
                                    "InsertToProductionDtlsS1");

                                cmd.Parameters.Add("@Result", SqlDbType.Int)
                                    .Direction =
                                    ParameterDirection.Output;

                                cmd.ExecuteNonQuery();
                            }
                        }

                        #endregion
                    }
                }
            }

            return "Success";
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }

    [WebMethod]
    public static void UpdateRank(object list)
    {
        JavaScriptSerializer js = new JavaScriptSerializer();
        var data = js.Deserialize<List<Dictionary<string, object>>>(
            js.Serialize(list)
        );

        string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(conStr))
        {
            con.Open();

            foreach (var item in data)
            {
                int id = Convert.ToInt32(item["id"]);
                int rank = Convert.ToInt32(item["rank"]);

                SqlCommand cmd = new SqlCommand(@"
                UPDATE tbl_MachineProductionHDR
                SET RankSrNo = @Rank
                WHERE WorkOrderID = @ID", con);

                cmd.Parameters.AddWithValue("@Rank", rank);
                cmd.Parameters.AddWithValue("@ID", id);
                cmd.ExecuteNonQuery();

                SqlCommand cmds = new SqlCommand(@"
                UPDATE tbl_WorkOrderHdr
                SET RankNo = @Rank
                WHERE ID = @ID", con);

                cmds.Parameters.AddWithValue("@Rank", rank);
                cmds.Parameters.AddWithValue("@ID", id);
                cmds.ExecuteNonQuery();
            }
        }
    }
}



using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
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
            cmd.Parameters.AddWithValue("@SP_Action", "GetCapacity");
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
}



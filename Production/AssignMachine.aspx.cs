using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class AssignMachine : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'AssignMachine.aspx'";
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
                LoadUser();
                FillGrid();
            }
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_AssignedMachines", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "GetList");
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void LoadUser()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SELECT ID, (AllocatedStage+'- '+MachineName) AS MachineName FROM tbl_MachineMaster WHERE IsActive = 1 AND IsDeleted=0", con);
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ddlMcName.DataSource = dt;
            ddlMcName.DataTextField = "MachineName";
            ddlMcName.DataValueField = "ID";
            ddlMcName.DataBind();
        }

        DataTable dts = new DataTable();
        SqlDataAdapter cmds = new SqlDataAdapter("SELECT ID,FullName FROM tbl_UserMaster WHERE UserRole = 'Operator' AND IsActivate= 1 and IsDeleted=0", con);
        cmds.Fill(dts);
        if (dts.Rows.Count > 0)
        {
            ddlOpName.DataSource = dts;
            ddlOpName.DataTextField = "FullName";
            ddlOpName.DataValueField = "ID";
            ddlOpName.DataBind();
        }
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument.ToString());

        if (e.CommandName == "RowDelete")
        {
            SqlCommand Cmd = new SqlCommand("SP_AssignedMachines", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@Id", id);
            Cmd.Parameters.AddWithValue("@ActionBy", Session["ID"].ToString());
            Cmd.Parameters.AddWithValue("@SP_Action", "DeleteAssiMachine");

            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Assigned Machine deleted successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Production/AssignMachine.aspx";
            Response.Redirect("/Alerts.aspx");
        }
    }

    protected void GVCompany_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        string MachineName = ddlMcName.SelectedValue;
        string OperatorName = ddlOpName.SelectedValue;

        DateTime FromDate = Convert.ToDateTime(txtFromDate.Text).Date;
        DateTime ToDate = Convert.ToDateTime(txtToDate.Text).Date;

        TimeSpan FromTime = TimeSpan.Parse(txtFromTime.Text);
        TimeSpan ToTime = TimeSpan.Parse(txtToTime.Text);

        using (SqlCommand cmd = new SqlCommand("SP_AssignedMachines", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@MachineID", SqlDbType.VarChar).Value = MachineName;
            cmd.Parameters.Add("@OperatorID", SqlDbType.VarChar).Value = OperatorName;
            cmd.Parameters.Add("@FromDate", SqlDbType.Date).Value = FromDate;
            cmd.Parameters.Add("@ToDate", SqlDbType.Date).Value = ToDate;
            cmd.Parameters.Add("@FromTime", SqlDbType.Time).Value = FromTime;
            cmd.Parameters.Add("@ToTime", SqlDbType.Time).Value = ToTime;
            cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();
            cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertMachine";

            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();


            Session["message"] = "Machine Assigned successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Production/AssignMachine.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void ddlMcName_SelectedIndexChanged(object sender, EventArgs e)
    {
        string MachineId = ddlMcName.SelectedValue;

        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_AssignedMachines", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@MachineID", MachineId);
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CheckMCAvailability");
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
           ScriptManager.RegisterStartupScript(this, this.GetType(),
             "alert",
             "alert('The selected machine is currently assigned to another operator and will be available after "
             + dt.Rows[0]["ToDate"].ToString() + " at "
             + dt.Rows[0]["ToTime"].ToString() + ".');",
             true);

            ddlMcName.SelectedValue = "";
        }
    }

    protected void ddlOpName_SelectedIndexChanged(object sender, EventArgs e)
    {
        string OperatorId = ddlOpName.SelectedValue;

        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_AssignedMachines", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@OperatorID", OperatorId);
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CheckOPAvailability");
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
              "alert",
              "alert('The selected Operator is currently assigned to another machine and will be available after "
              + dt.Rows[0]["ToDate"].ToString() + " at "
              + dt.Rows[0]["ToTime"].ToString() + ".');",
              true);

            ddlOpName.SelectedValue = "";
        }
    }
}



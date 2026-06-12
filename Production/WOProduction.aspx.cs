using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;


public partial class WOProduction : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserCode"] == null)
        {
            Response.Redirect("../Login.aspx");
        }
        else
        {
            spdate.InnerText = DateTime.Now.Date.ToString("dd-MM-yyyy");
            if (!IsPostBack)
            {
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WOProduction.aspx'";
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
                BindOperators();
                GetOperatorDetails();
                FillGrid();
            }
        }
    }

    private void BindOperators()
    {
        if (Session["Role"].ToString() == "Admin")
        {
            spnAdmin.Visible = true;
        }
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter(@"SELECT UM.ID,UM.FullName FROM tbl_UserMaster UM
                LEFT JOIN tbl_AssignedMachines AM ON AM.OperatorID = UM.ID
                LEFT JOIN tbl_MachineMaster MM ON MM.ID = AM.MachineID
                WHERE UM.UserRole = 'Operator' AND UM.IsActivate = 1
                AND UM.IsDeleted =0 AND MM.AllocatedStage = 'Stage 1'", con);
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ddlOperators.DataSource = dt;
            ddlOperators.DataTextField = "FullName";
            ddlOperators.DataValueField = "ID";
            ddlOperators.DataBind();
        }
    }

    private void GetOperatorDetails()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductionsPlanning", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(Session["ID"].ToString()));
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "GetOperatorDetails");
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            spshift.InnerText = "General";
            spoperator.InnerText = dt.Rows[0]["OperatorName"].ToString();
            spmachine.InnerText = dt.Rows[0]["MachineName"].ToString();
            sptarget.InnerText = dt.Rows[0]["TargetQty"].ToString();
            spprod.InnerText = dt.Rows[0]["CompletedQty"].ToString();
            sprej.InnerText = dt.Rows[0]["RejectedQty"].ToString();
        }

    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductionsPlanning", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "AssignWorkOrder");
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        LinkButton btn = (LinkButton)e.CommandSource;

        GridViewRow row = (GridViewRow)btn.NamingContainer;

        TextBox txtQty = (TextBox)row.FindControl("txtQty");

        string qty = txtQty.Text;

        SqlCommand Cmd = new SqlCommand("SP_ProductionsPlanning", con);
        Cmd.CommandType = CommandType.StoredProcedure;
        Cmd.Parameters.AddWithValue("@Id", Convert.ToInt32(e.CommandArgument.ToString()));
        Cmd.Parameters.AddWithValue("@ReceivedQty", qty);
        if (e.CommandName == "AppQty")
        {
            Cmd.Parameters.AddWithValue("@SP_Action", "S1CompletedQty");
            Session["message"] = "Qty Completed successfully.";
        }
        else
        {
            Cmd.Parameters.AddWithValue("@SP_Action", "S1RejectedQty");
            Session["message"] = "Qty Rejectd successfully.";
        }
        con.Open();
        Cmd.ExecuteNonQuery();
        con.Close();


        Session["icon"] = "success";
        Session["time"] = "2000";
        Session["url"] = "/Production/WOProduction.aspx";
        Response.Redirect("/Alerts.aspx");
    }

    protected void GVCompany_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

        }
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void ddlOperators_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
}



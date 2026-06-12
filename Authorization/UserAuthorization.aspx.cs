using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;


public partial class UserAuthorization : System.Web.UI.Page
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
            if (!IsPostBack)
            {
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'UserAuthorization.aspx'";
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

                BindRole();
                GridDiv.Visible = false;
            }
        }
    }

    protected void BindRole()
    {
        try
        {
            DataTable Dt = new DataTable();

            SqlDataAdapter Da = new SqlDataAdapter("SELECT ID,Roles FROM tbl_RoleMaster WHERE Roles != 'Admin' AND IsDeleted = 0",con);
            Da.Fill(Dt);

            ddlUserRole.DataTextField = "Roles";
            ddlUserRole.DataValueField = "ID";
            ddlUserRole.DataSource = Dt;
            ddlUserRole.DataBind();

        }
        catch (Exception)
        {
            throw;
        }
    }

    protected void BindUser()
    {
        try
        {
            ddlUserName.Items.Clear();

            DataTable Dt = new DataTable();

            SqlDataAdapter Da = new SqlDataAdapter("SELECT ID,FullName FROM tbl_UserMaster WHERE UserRole='" + ddlUserRole.SelectedItem.Text + "' AND IsDeleted=0 AND IsActivate=1", con);
            Da.Fill(Dt);
            ddlUserName.DataTextField = "FullName";
            ddlUserName.DataValueField = "ID";
            ddlUserName.DataSource = Dt;
            ddlUserName.DataBind();

            ddlUserName.Items.Insert(0, new ListItem("--Select User--", ""));
        }
        catch (Exception)
        {
            throw;
        }
    }

    protected void ddlUserRole_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlUserRole.SelectedValue != "")
        {
            BindUser();
            GridDiv.Visible = false;
        }
    }

    protected void ddlUserName_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            GridDiv.Visible = true;

            gvUserAuthorization.DataSource = null;
            gvUserAuthorization.DataBind();

            DataTable Dt = new DataTable();
            SqlDataAdapter Da = new SqlDataAdapter("SELECT TOP 3 * FROM tbl_UserRoleAuthorization WHERE UserID='" + ddlUserName.SelectedValue + "'", con);
            Da.Fill(Dt);
            if (Dt.Rows.Count > 0)
            {
                btnSubmit.Text = "Update";
                DataTable Dtt = new DataTable();
                SqlDataAdapter Daa = new SqlDataAdapter("SELECT UR.ID AS UID,AP.ID AS MenuId,AP.MenuName AS MenuName, " +
                    " AP.PageName AS PageName ,UR.UserID AS UserRoleID ,UR.PageAccess AS PageAccess," +
                    " UR.PagesButtonAccess AS PageButtonAccess FROM tbl_AuthPages AP " +
                    " LEFT JOIN tbl_UserRoleAuthorization UR ON AP.ID = UR.MenuId" +
                    " AND UR.UserID ='" + ddlUserName.SelectedValue + "' ORDER BY AP.ID", con);
                Daa.Fill(Dtt);
                gvUserAuthorization.EmptyDataText = "No Records Found";
                gvUserAuthorization.DataSource = Dtt;
                gvUserAuthorization.DataBind();

            }
            else
            {
                btnSubmit.Text = "Save";
                DataTable Dttt = new DataTable();
                SqlDataAdapter Daaa = new SqlDataAdapter("SELECT ID AS UID,ID AS MenuId,MenuName AS MenuName, PageName AS PageName ,'' AS PageAccess,'' AS PageButtonAccess FROM tbl_AuthPages", con);
                Daaa.Fill(Dttt);
                gvUserAuthorization.EmptyDataText = "No Records Found";
                gvUserAuthorization.DataSource = Dttt;

                gvUserAuthorization.DataBind();
            }
        }
        catch (Exception)
        {
            throw;
        }
    }

    protected void gvUserAuthorization_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CheckBox chkpages = (CheckBox)e.Row.FindControl("chkPages");
            CheckBox chkpagesview = (CheckBox)e.Row.FindControl("chkPagesView");

            Label PageAccess = (Label)e.Row.FindControl("lblPageAccess");
            Label PagesButtonAccess = (Label)e.Row.FindControl("lblPageButtonAccess");

            chkpages.Checked = PageAccess.Text == "True" ? true : false;
            chkpagesview.Checked = PagesButtonAccess.Text == "True" ? true : false;
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            if (btnSubmit.Text == "Update")
            {
                SqlCommand cmd = new SqlCommand("SP_AuthorizationMaster", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserID", ddlUserName.SelectedItem.Value);
                cmd.Parameters.AddWithValue("@SP_Action", "AuthorizationDelete");
                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }

            foreach (GridViewRow g1 in gvUserAuthorization.Rows)
            {
                string menuname = (g1.FindControl("lblMenuName") as Label).Text;
                string pagename = (g1.FindControl("lblPageName") as Label).Text;
                string menu = (g1.FindControl("lblMenuId") as Label).Text;
                int userId = Convert.ToInt32(ddlUserName.SelectedValue);
                bool pageChk = (g1.FindControl("chkPages") as CheckBox).Checked;
                bool pageviewChk = (g1.FindControl("chkPagesView") as CheckBox).Checked;

                SqlCommand cmd = new SqlCommand("SP_AuthorizationMaster", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserID", ddlUserName.SelectedItem.Value);
                cmd.Parameters.AddWithValue("@UserName", ddlUserName.SelectedItem.Text);
                cmd.Parameters.AddWithValue("@MenuId", menu);
                cmd.Parameters.AddWithValue("@MenuName", menuname);
                cmd.Parameters.AddWithValue("@PageName", pagename);
                cmd.Parameters.AddWithValue("@PageAccess", pageChk);
                cmd.Parameters.AddWithValue("@PagesButtonAccess", pageviewChk);
                cmd.Parameters.AddWithValue("@ActionBy", Session["ID"].ToString());
                cmd.Parameters.AddWithValue("@SP_Action", "AuthorizationInsert");
                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }

            Session["message"] = "User Authorization created successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Authorization/UserAuthorization.aspx";
            Response.Redirect("/Alerts.aspx");
        }
        catch (Exception)
        {
            throw;
        }
    }
}



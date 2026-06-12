using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class RoleMaster : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["ID"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }
        else
        {
            if (!IsPostBack)
            {
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'RoleMaster.aspx'";
                        SqlCommand cmd = new SqlCommand(query, con);
                        cmd.Parameters.AddWithValue("@UserID", username);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result == null || result.ToString() != "True")
                        {
                            Response.Redirect("/AccessDenied.aspx");
                        }
                    }
                }

                FillGrid();
            }
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_UserMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "RoleList");
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument.ToString());
        if (e.CommandName == "RowDelete")
        {
            SqlCommand Cmd = new SqlCommand("SP_UserMaster", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@SP_Action", "DeleteRole");
            Cmd.Parameters.AddWithValue("@Id", id);
            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Role deleted successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/RoleMaster.aspx";
            Response.Redirect("/Alerts.aspx");
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_UserMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@UserRole", SqlDbType.VarChar).Value = txtRole.Text.Trim();
            cmd.Parameters.Add("@FullName", SqlDbType.VarChar).Value = ddlDepartment.SelectedValue;
            cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertRole";
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Role created successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/RoleMaster.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void txtRole_TextChanged(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtRole.Text))
        {
            return;
        }

        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_UserMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@UserRole", txtRole.Text.Trim().ToUpper());
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "VerifyRole");
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                 "alert", "alert('This role is currently assigned and cannot be reused. Please select a different role.');", true);
            txtRole.Text = "";
        }
    }
}



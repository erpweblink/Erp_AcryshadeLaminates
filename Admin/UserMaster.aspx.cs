using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class UserMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'UserList.aspx'";
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


                DataTable dt = new DataTable();
                SqlDataAdapter cmd = new SqlDataAdapter("SP_UserMaster", con);
                cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
                cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "RoleListForUser");
                cmd.Fill(dt);
                if (dt.Rows.Count > 0)
                {
                    ddlRoles.DataSource = dt;
                    ddlRoles.DataTextField = "Roles";
                    ddlRoles.DataValueField = "Roles";
                    ddlRoles.DataBind();

                    ddlRoles.Items.Insert(0, new ListItem("--Select Role--", ""));
                }

                if (Request.QueryString["Id"] != null)
                {
                    string ID = objcls.Decrypt(Request.QueryString["Id"].ToString());
                    hdnId.Value = ID;
                    LoadData(ID);

                }
            }
        }
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_UserMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "UserById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtUserFName.Text = dt.Rows[0]["FullName"].ToString();
            txtUserCnt.Text = dt.Rows[0]["MobileNo"].ToString();
            txtUserMail.Text = dt.Rows[0]["EmailId"].ToString();
            txtUserPassword.Text = dt.Rows[0]["LoginPass"].ToString();
            ddlRoles.SelectedValue = dt.Rows[0]["UserRole"].ToString();
            btnsave.Text = "Update";
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_UserMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@FullName", SqlDbType.VarChar).Value = txtUserFName.Text;
            cmd.Parameters.Add("@MobileNo", SqlDbType.VarChar).Value = txtUserCnt.Text;
            cmd.Parameters.Add("@EmialId", SqlDbType.VarChar).Value = txtUserMail.Text;
            cmd.Parameters.Add("@Password", SqlDbType.VarChar).Value = txtUserPassword.Text;
            cmd.Parameters.Add("@UserRole", SqlDbType.VarChar).Value = ddlRoles.SelectedValue;

            if (btnsave.Text == "Update")
            {
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(hdnId.Value);
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateData";
            }
            else
            {
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertData";
            }
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            if (btnsave.Text == "Update")
            {
                Session["message"] = "User updated successfully.";
            }
            else
            {
                Session["message"] = "User created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/UserList.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void btn_UsList_click(object sender, EventArgs e)
    {
        Response.Redirect("UserList.aspx");
    }

    protected void txtEmailId_TextChange(object sender, EventArgs e)
    {
        string email = txtUserMail.Text.Trim();
        if (string.IsNullOrWhiteSpace(email))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "alert", "alert('Please enter Email ID.');", true);
            txtUserMail.Focus();
            return;
        }

        string emailPattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

        if (!Regex.IsMatch(email, emailPattern))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "alert", "alert('Please enter valid Email ID.');", true);

            txtUserMail.Text = "";
            txtUserMail.Focus();
            return;
        }

        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_DealerMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CheckEmialId");
        cmd.SelectCommand.Parameters.AddWithValue("@EmialId", txtUserMail.Text.Trim());
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Email ID Already Exist.');", true);
            txtUserMail.Text = "";
            return;
        }
    }
}



using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;

public partial class Login : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Session["message"] = "";
            Session["icon"] = "";
            Session["time"] = "";
            Session["url"] = "";

            Session.Abandon();
            // Pre-fill login form using cookies (Remember Me)
            if (Request.Cookies["Username"] != null)
                txtUsername.Text = Request.Cookies["Username"].Value;

            if (Request.Cookies["Password"] != null)
                txtPassword.Attributes.Add("value", Request.Cookies["Password"].Value);

            if (Request.Cookies["Username"] != null && Request.Cookies["Password"] != null)
                chkremember.Checked = true;
        }
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            SqlDataAdapter sad = new SqlDataAdapter("SELECT * FROM tbl_UserMaster WHERE EmailId = @EmailId AND LoginPass = @LogPass", con);
            sad.SelectCommand.Parameters.AddWithValue("@EmailId", txtUsername.Text.Trim());
            sad.SelectCommand.Parameters.AddWithValue("@LogPass", txtPassword.Text.Trim());
            DataTable dt = new DataTable();
            sad.Fill(dt);

            if (dt.Rows.Count > 0)
            {
                string Username = dt.Rows[0]["FullName"].ToString();
                string Role = dt.Rows[0]["UserRole"].ToString();
                string status = dt.Rows[0]["IsActivate"].ToString();
                if (status == "True")
                {
                    FormsAuthentication.SetAuthCookie(txtUsername.Text.Trim(), chkremember.Checked);

                    if (chkremember.Checked)
                    {
                        Response.Cookies["Username"].Value = txtUsername.Text.ToLower().Trim();
                        Response.Cookies["Password"].Value = txtPassword.Text.Trim();
                        Response.Cookies["Username"].Expires = DateTime.Now.AddDays(2);
                        Response.Cookies["Password"].Expires = DateTime.Now.AddDays(2);
                    }
                    else
                    {
                        // Remove the cookie if "Remember Me" is not checked
                        if (Request.Cookies["RememberMe"] != null)
                        {
                            Response.Cookies["Username"].Expires = DateTime.Now.AddDays(-1);
                            Response.Cookies["Password"].Expires = DateTime.Now.AddDays(-1);
                        }
                    }
                    if (!string.IsNullOrEmpty(Username))
                    {
                        Session["ID"] = dt.Rows[0]["ID"].ToString();
                        Session["Username"] = dt.Rows[0]["EmailId"].ToString();
                        Session["Role"] = dt.Rows[0]["UserRole"].ToString();
                        Session["EmailID"] = dt.Rows[0]["EmailID"].ToString();
                        Session["Mobileno"] = dt.Rows[0]["MobileNo"].ToString();
                        Session["UserCode"] = dt.Rows[0]["UserCode"].ToString();

                        string script = @"
                            Swal.fire({
                                icon: 'success',
                                text: 'Login successfully..!!',
                                showConfirmButton: false,
                                timer: 2000,
                                timerProgressBar: true
                            }).then(function () {
                                window.location.href = 'Admin/Dashboard.aspx';
                            });";

                        ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
                    }
                }
                else
                {
                    txtUsername.Text = ""; txtPassword.Text = "";
                    string script = @"
                            Swal.fire({
                                icon: 'warning',
                                text: 'Login Failed, Activate Your Account First..!!',
                                showConfirmButton: false,
                                timer: 3000,
                                timerProgressBar: true
                            }).then(function () {
                                window.location.href = '/Login.aspx';
                            });";

                    ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
                }
            }
            else
            {
                txtUsername.Text = ""; txtPassword.Text = "";

                string script = @"
                            Swal.fire({
                                icon: 'error',
                                text: 'Login Failed Incorrect UserName or Password..!!',
                                showConfirmButton: false,
                                timer: 4000,
                                timerProgressBar: true
                            }).then(function () {
                                window.location.href = '/Login.aspx';
                            });";

                ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
            }

        }
        catch (Exception)
        {
            throw;
        }
        finally
        {
            con.Close();
            con.Dispose();
        }

    }

}


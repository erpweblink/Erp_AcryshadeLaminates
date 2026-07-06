using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;


public partial class ProfilePage : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadProfile();
        }
    }

    void LoadProfile()
    {
        string username = Session["ID"].ToString();

        SqlCommand cmd = new SqlCommand("SELECT * FROM tbl_UserMaster WHERE ID=@Username", con);
        cmd.Parameters.AddWithValue("@Username", username);

        con.Open();
        SqlDataReader dr = cmd.ExecuteReader();

        if (dr.Read())
        {
            txtName.Text = dr["FullName"].ToString();
            txtUsername.Text = dr["EmailId"].ToString();
            txtPassword.Text = dr["LoginPass"].ToString();
            txtMobile.Text = dr["MobileNo"].ToString();
        }

        con.Close();
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        string photo = "";


        SqlCommand cmd = new SqlCommand();


        cmd.CommandText = @"UPDATE tbl_UserMaster
                                SET FullName=@Name,
                                    EmailId=@Username,
                                    LoginPass=@Password,
                                    MobileNo=@Mobile
                                WHERE ID=@OldUsername";

        cmd.Parameters.AddWithValue("@Photo", photo);


        cmd.Connection = con;

        cmd.Parameters.AddWithValue("@Name", txtName.Text);
        cmd.Parameters.AddWithValue("@Username", txtUsername.Text);
        cmd.Parameters.AddWithValue("@Password", txtPassword.Text);
        cmd.Parameters.AddWithValue("@Mobile", txtMobile.Text);
        cmd.Parameters.AddWithValue("@OldUsername", Session["ID"].ToString());

        con.Open();
        cmd.ExecuteNonQuery();
        con.Close();

        Session["Username"] = txtUsername.Text;

        lblMessage.Text = "Profile updated successfully.";
        LoadProfile();
    }


    protected void txtEmail_TextChanged(object sender, EventArgs e)
    {
        cvEmail.IsValid = true;

        string email = txtUsername.Text.Trim();

        if (EmailExists(email))
        {
            txtUsername.Text = "";
            cvEmail.IsValid = false;
            txtUsername.Focus();
        }
    }


    private bool EmailExists(string email)
    {
        bool exists = false;

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = "SELECT COUNT(*) FROM tbl_UserMaster WHERE EmailId=@Email AND ID != @ID";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@ID", HttpContext.Current.Session["ID"].ToString());

                con.Open();

                int count = Convert.ToInt32(cmd.ExecuteScalar());

                exists = count > 0;
            }
        }

        return exists;
    }

}



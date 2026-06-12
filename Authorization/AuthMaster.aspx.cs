using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;


public partial class AuthMaster : System.Web.UI.Page
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
                FillGrid();
            }
        }
    }

    protected void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_AuthorizationMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "GetAuthList");
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_AuthorizationMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@MenuName", SqlDbType.VarChar).Value = txtMenuName.Text.Trim();
            cmd.Parameters.Add("@PageName", SqlDbType.VarChar).Value = txtPageName.Text.Trim();
            cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "CreateAuth";
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Menu created successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Authorization/AuthMaster.aspx";
            Response.Redirect("/Alerts.aspx");
        }
    }
}



using System;
using System.Configuration;
using System.Data.SqlClient;


public partial class AccessDenied : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserCode"] == null)
        {
            Response.Redirect("../Login.aspx");
        }

        string url = "Admin/Dashboard.aspx";
        if (Session["Role"].ToString() == "Dealer")
        {
            url = "Admin/OrderHistory.aspx";
        }
        lblPdfUrl.HRef = url;
    }
}



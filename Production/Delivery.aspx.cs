using System;
using System.Configuration;
using System.Data.SqlClient;


public partial class Delivery : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();
    
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }
   
}



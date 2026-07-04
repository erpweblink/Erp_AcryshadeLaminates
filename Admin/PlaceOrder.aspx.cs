using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;


public partial class PlaceOrder : System.Web.UI.Page
{
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'PlaceOrder.aspx'";
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
            }
        }
    }

    [WebMethod]
    public static string GetCartData()
    {
        DataTable dt = new DataTable();

        string cs = ConfigurationManager
            .ConnectionStrings["constr"]
            .ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                @"SELECT COUNT(*) AS Count
                  FROM tbl_DealersOrderTemp WHERE DealersID = @DealersID AND CAST(AddedDate as date)=CAST(@AddedDate as date)",
                con);
            da.SelectCommand.Parameters.AddWithValue("@DealersID", HttpContext.Current.Session["ID"].ToString());
            da.SelectCommand.Parameters.AddWithValue("@AddedDate", DateTime.Now);
            da.Fill(dt);
        }

        return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static string GetProducts()
    {
        DataTable dt = new DataTable();

        string cs = ConfigurationManager
            .ConnectionStrings["constr"]
            .ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                @"SELECT ID,ProductName,Size,ImagenamePath,FavoriteProduct,IsNull(FavoriteProductRank,0) as FavoriteProductRank
                  FROM tbl_ProdcutMaster WHERE IsActive = 1 AND isdeleted = 0",
                con);

            da.Fill(dt);
        }

        return Newtonsoft.Json.JsonConvert.SerializeObject(dt);
    }

    [WebMethod]
    public static string AddToCart(int productId,string productN, string size,string productType, int qty,string imagename)
    {
        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            SqlCommand cmd = new SqlCommand(@"
            INSERT INTO tbl_DealersOrderTemp
            (ProductId,ProductName,ProductType,Size,Qty,ImagePathName,DealersID,AddedDate)
            VALUES (@ProductId,@ProductName,@ProductType,@Size,@Qty,@ImagePath,@DealersID,@AddedDate)", con);

            cmd.Parameters.AddWithValue("@ProductId", productId);
            cmd.Parameters.AddWithValue("@ProductName", productN);
            cmd.Parameters.AddWithValue("@Size", size);
            cmd.Parameters.AddWithValue("@ProductType", productType);
            cmd.Parameters.AddWithValue("@Qty", qty);
            cmd.Parameters.AddWithValue("@ImagePath", imagename);
            cmd.Parameters.AddWithValue("@DealersID", HttpContext.Current.Session["ID"].ToString());
            cmd.Parameters.AddWithValue("@AddedDate", DateTime.Now);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        return "Success";
    }

}



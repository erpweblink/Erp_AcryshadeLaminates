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
                @"SELECT ID,ProductName,Size,ImagenamePath,FavoriteProduct
                  FROM tbl_ProdcutMaster WHERE IsActive = 1",
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


    [System.Web.Services.WebMethod]
    public static string SaveCustomization()
    {
        HttpContext context = HttpContext.Current;

        int productId = Convert.ToInt32(context.Request.Form["productId"]);
        string size = context.Request.Form["size"];
        string note = context.Request.Form["note"];
        string prodImaName = context.Request.Form["prodImaName"];

        HttpPostedFile file = context.Request.Files["file"];

        string filePath = "";

        if (file != null && file.ContentLength > 0)
        {
            string fileName = Guid.NewGuid() + System.IO.Path.GetExtension(file.FileName);
            filePath = "~/CustomizationImages/" + fileName;

            string physicalPath = context.Server.MapPath(filePath);
            file.SaveAs(physicalPath);
        }
        else
        {
            filePath = prodImaName.Replace("/Content/", "~/");
        }

        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            //SqlCommand cmd = new SqlCommand(@"
            //INSERT INTO tbl_Customization
            //(ProductId, Size, Note, ImagePath)
            //VALUES (@ProductId, @Size, @Note, @ImagePath)", con);

            //cmd.Parameters.AddWithValue("@ProductId", productId);
            //cmd.Parameters.AddWithValue("@Size", size);
            //cmd.Parameters.AddWithValue("@Note", note);
            //cmd.Parameters.AddWithValue("@ImagePath", filePath);

            //con.Open();
            //cmd.ExecuteNonQuery();
        }

        return "success";
    }
}



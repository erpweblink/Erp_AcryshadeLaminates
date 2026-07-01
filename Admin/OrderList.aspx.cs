using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;


public partial class OrderList : System.Web.UI.Page
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
                BindOrder();
            }
        }
    }

    protected void BindOrder()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter(@"SELECT *
                    FROM tbl_DealersOrderTemp
                    WHERE DealersID =@DealersID
                    AND CAST(AddedDate as date) = (
                        SELECT CAST(MAX(AddedDate) as date)
                        FROM tbl_DealersOrderTemp
                        WHERE DealersID = @DealersID
                    )", con);
        cmd.SelectCommand.Parameters.AddWithValue("@DealersID", Session["ID"].ToString());
        cmd.SelectCommand.Parameters.AddWithValue("@AddedDate", DateTime.Now);
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();

            List<Dictionary<string, object>> rows =
                new List<Dictionary<string, object>>();

            foreach (DataRow dr in dt.Rows)
            {
                Dictionary<string, object> row =
                    new Dictionary<string, object>();

                foreach (DataColumn col in dt.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }

                rows.Add(row);
            }

            string json = js.Serialize(rows);

            ClientScript.RegisterStartupScript(
                this.GetType(),
                "LoadWorkOrder",
                "loadWorkOrderData(" + json + ");",
                true);


        }

    }

    [WebMethod]
    public static string DeleteTempOrder(int id)
    {
        try
        {
            string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = "DELETE FROM tbl_DealersOrderTemp WHERE ID=@Id";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Id", id);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            return "Success";
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            int Id = 0;

            // DETAIL VALUES
            string[] ProductId = Request.Form.GetValues("ProductId[]");
            string[] ProductName = Request.Form.GetValues("ProductName[]");
            string[] SheetNo = Request.Form.GetValues("SheetNo[]");
            string[] Description = Request.Form.GetValues("Description[]");
            string[] Size = Request.Form.GetValues("Size[]");
            string[] Qty = Request.Form.GetValues("Qty[]");
            string[] SqFeet = Request.Form.GetValues("SqFeet[]");
            string[] Unit = Request.Form.GetValues("Unit[]");
            string[] ProdImageName = Request.Form.GetValues("ProdImageName[]");
            string[] TempIDds = Request.Form.GetValues("rowid[]");

            HttpFileCollection files = Request.Files;

            if (ProductId == null || ProductId.Length == 0)
            {
                Session["message"] = "No products have been selected. Please add at least one product before placing your order.";
                Session["icon"] = "warning";
                Session["time"] = "4000";
                Session["url"] = "/Admin/PlaceOrder.aspx";

                Response.Redirect("/Alerts.aspx");
                return;
            }

            con.Open();

            using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Dealer", Session["ID"].ToString());
                cmd.Parameters.AddWithValue("@SP_Action", "PlaceorderHDR");

                HttpPostedFile filess = null;

                if (files.Count > 0)
                {
                    filess = files[0];
                }

                if (filess != null && filess.ContentLength > 0)
                {
                    string fileName = Guid.NewGuid() + "_" + Path.GetFileName(filess.FileName);

                    string folderPath = Server.MapPath("~/Content/DealersInvoice/");

                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fullPath = Path.Combine(folderPath, fileName);

                    FileMCImage.SaveAs(fullPath);

                    cmd.Parameters.AddWithValue("@UploadedImage", "~/DealersInvoice/" + fileName);

                }
                else
                {
                    cmd.Parameters.AddWithValue("@UploadedImage", DBNull.Value);
                }
                cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);

            }


            int fileIndex = 1;
            // LOOP THROUGH ALL ROWS
            for (int i = 0; i < ProductName.Length; i++)
            {
                using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "PlaceorderDtls");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);
                    cmd.Parameters.AddWithValue("@ProductId", string.IsNullOrWhiteSpace(ProductId[i]) ? "" : ProductId[i]);
                    cmd.Parameters.AddWithValue("@ProductName", string.IsNullOrWhiteSpace(ProductName[i]) ? "" : ProductName[i]);
                    cmd.Parameters.AddWithValue("@Description", string.IsNullOrWhiteSpace(Description[i]) ? "" : Description[i]);
                    cmd.Parameters.AddWithValue("@Size", string.IsNullOrWhiteSpace(Size[i]) ? "0" : Size[i]);
                    cmd.Parameters.AddWithValue("@Qty", string.IsNullOrWhiteSpace(Qty[i]) ? "0" : Qty[i]);


                    HttpPostedFile file = null;

                    if (fileIndex < files.Count)
                    {
                        file = files[fileIndex];
                        fileIndex++;
                    }


                    if (file != null && file.ContentLength > 0)
                    {
                        string fileName = Guid.NewGuid() + "_" + Path.GetFileName(file.FileName);

                        string folderPath = Server.MapPath("~/Content/WOCustomProducts/");

                        if (!Directory.Exists(folderPath))
                        {
                            Directory.CreateDirectory(folderPath);
                        }

                        string fullPath = Path.Combine(folderPath, fileName);

                        //  SaveCompressedImage(file, fullPath, quality: 60, maxWidth: 800);


                        cmd.Parameters.AddWithValue(
                            "@UploadedImage",
                            "~/WOCustomProducts/" + fileName
                        );
                        cmd.Parameters.AddWithValue("@Type", "Custom");
                    }
                    else
                    {
                        if (!string.IsNullOrWhiteSpace(ProdImageName[i]) && ProdImageName[i] != "null")
                        {
                            cmd.Parameters.AddWithValue("@UploadedImage", ProdImageName[i]);
                            cmd.Parameters.AddWithValue("@Type", "Regular");
                        }
                    }


                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();

                }


                SqlCommand cmds = new SqlCommand("DELETE tbl_DealersOrderTemp WHERE ID = @ID", con);
                cmds.Parameters.AddWithValue("@ID", TempIDds[i]);
                cmds.ExecuteNonQuery();
            }

            Session["message"] = "Order has been Placed.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/PlaceOrder.aspx";

            Response.Redirect("/Alerts.aspx");
        }
        catch (Exception)
        {
            con.Close();
            throw;
        }
        finally
        {
            con.Close();
        }
    }

    public static void SaveCompressedImage(HttpPostedFile file, string fullPath, int quality = 60, int maxWidth = 800)
    {
        using (var image = Image.FromStream(file.InputStream))
        {
            int newWidth = image.Width;
            int newHeight = image.Height;

            // resize if image is too large
            if (image.Width > maxWidth)
            {
                newWidth = maxWidth;
                newHeight = (image.Height * maxWidth) / image.Width;
            }

            using (var bitmap = new Bitmap(image, new Size(newWidth, newHeight)))
            {
                ImageCodecInfo jpgEncoder = ImageCodecInfo
                    .GetImageDecoders()
                    .First(c => c.FormatID == ImageFormat.Jpeg.Guid);

                Encoder encoder = Encoder.Quality;
                EncoderParameters encParams = new EncoderParameters(1);

                encParams.Param[0] = new EncoderParameter(encoder, quality);

                bitmap.Save(fullPath, jpgEncoder, encParams);
            }
        }
    }
}



using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.Services;


public partial class Notifications : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID --AND PageName = 'PlaceOrder.aspx'";
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

                if (Request.QueryString["OrderID"] != null)
                {
                    hdnOrderID.Value = Request.QueryString["OrderID"].ToString();
                }
            }
        }
    }

    [WebMethod]
    public static List<Dictionary<string, object>> GetOrders(string orderID)
    {
        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        Dictionary<int, Dictionary<string, object>> orders = new Dictionary<int, Dictionary<string, object>>();

        using (SqlConnection con = new SqlConnection(cs))
        {
            con.Open();

            string query = @"
            SELECT DH.ID,DH.OrderID, UM.FullName AS DealerName,CONVERT(varchar(10), DH.CreatedDate, 105) as CreatedDate,
                DD.ProductID, DD.ProductName, DD.ProductType, DD.Size,
                DD.Qty, DD.ImagePathName,DD.ProductNote,DH.InvoicePath as AttachedPath,
                CASE WHEN DH.HoldStatus = 1 AND DH.HoldStatus IS NOT NULL THEN 'ON HOLD' ELSE '' END as HoldStatus
            FROM tbl_DealersOrderHDR DH
            INNER JOIN tbl_DealersOrderDTLs DD
                    ON DD.HeaderID = DH.ID
            LEFT JOIN tbl_UserMaster UM
                    ON UM.ID = DH.DealerID
            WHERE ( @OrderID IS NULL OR @OrderID = '' OR DH.ID = @OrderID) AND DH.OrderStatus ='Order Placed'
            ORDER BY DH.ID DESC";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@OrderID", Decrypt(orderID));
            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                int id = Convert.ToInt32(dr["ID"]);

                // CREATE HEADER OBJECT IF NOT EXISTS
                if (!orders.ContainsKey(id))
                {
                    orders[id] = new Dictionary<string, object>();

                    orders[id]["ID"] = id;
                    orders[id]["EnID"] = encrypt(id.ToString());
                    orders[id]["OrderID"] = dr["OrderID"];
                    orders[id]["DealerName"] = dr["DealerName"];
                    orders[id]["CreatedDate"] = dr["CreatedDate"];
                    orders[id]["AttachedPath"] = dr["AttachedPath"];
                    orders[id]["HoldStatus"] = dr["HoldStatus"];
                    orders[id]["Products"] = new List<Dictionary<string, object>>();
                }

                // ADD PRODUCT
                var product = new Dictionary<string, object>();
                product["ProductID"] = dr["ProductID"];
                product["ProductName"] = dr["ProductName"].ToString();
                product["ProductNote"] = dr["ProductNote"].ToString();
                product["ProductType"] = dr["ProductType"].ToString();
                product["Size"] = dr["Size"].ToString();
                product["Qty"] = dr["Qty"];
                product["ImagePathName"] = dr["ImagePathName"].ToString().Replace("~", "");

                ((List<Dictionary<string, object>>)orders[id]["Products"]).Add(product);
            }
        }

        return new List<Dictionary<string, object>>(orders.Values);
    }

    [WebMethod]
    public static object RejectOrder(string id)
    {
        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
        using (SqlConnection con = new SqlConnection(cs))
        {
            con.Open();

            string query = @"UPDATE tbl_DealersOrderHDR SET OrderStatus='Order Rejected',ApproveOrNotDate = GETDATE() WHERE ID = @OrderID ";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@OrderID", Decrypt(id));
            cmd.ExecuteNonQuery();
        }
        return "success";
    }
    public static string encrypt(string encryptString)
    {
        string EncryptionKey = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        byte[] clearBytes = Encoding.Unicode.GetBytes(encryptString);
        using (Aes encryptor = Aes.Create())
        {
            Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] {
            0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76
        });
            encryptor.Key = pdb.GetBytes(32);
            encryptor.IV = pdb.GetBytes(16);
            using (MemoryStream ms = new MemoryStream())
            {
                using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                {
                    cs.Write(clearBytes, 0, clearBytes.Length);
                    cs.Close();
                }
                encryptString = Convert.ToBase64String(ms.ToArray());
            }
        }
        return encryptString;
    }
    public static string Decrypt(string cipherText)
    {
        string EncryptionKey = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        cipherText = cipherText.Replace(" ", "+");
        byte[] cipherBytes = Convert.FromBase64String(cipherText);
        using (Aes encryptor = Aes.Create())
        {
            Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] {
            0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76
        });
            encryptor.Key = pdb.GetBytes(32);
            encryptor.IV = pdb.GetBytes(16);
            using (MemoryStream ms = new MemoryStream())
            {
                using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateDecryptor(), CryptoStreamMode.Write))
                {
                    cs.Write(cipherBytes, 0, cipherBytes.Length);
                    cs.Close();
                }
                cipherText = Encoding.Unicode.GetString(ms.ToArray());
            }
        }
        return cipherText;
    }
}



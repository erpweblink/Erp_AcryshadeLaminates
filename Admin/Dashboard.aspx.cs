using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Services;


public partial class Dashboard : System.Web.UI.Page
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
                if (Session["Role"].ToString() != "Admin")
                {
                    divAdmin.Visible = false;
                }
                GetDashboard();
            }
        }

    }

    protected void GetDashboard()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_DashboardDetails", con);
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CardsDetails");
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            lbldealerCount.InnerText = dt.Rows[0]["DealersCount"].ToString();
            lblStages.InnerText = dt.Rows[0]["StageCount"].ToString();
            lblMachines.InnerText = dt.Rows[0]["MachineCount"].ToString();
            lblCapacity.InnerText = dt.Rows[0]["UnitCapacity"].ToString();
        }
        else
        {
            lbldealerCount.InnerText = "0";
            lblStages.InnerText = "0";
            lblMachines.InnerText = "0";
            lblCapacity.InnerText = "0";
        }
    }

    [WebMethod]
    public static object GetCardDetails(string cardName)
    {
        List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            SqlCommand cmd = new SqlCommand("SP_DashboardDetails", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", cardName);

            con.Open();

            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    Dictionary<string, object> row = new Dictionary<string, object>();

                    for (int i = 0; i < dr.FieldCount; i++)
                    {
                        row.Add(dr.GetName(i), dr[i]);
                    }

                    rows.Add(row);
                }
            }
        }

        return rows;
    }

    [WebMethod]
    public static List<Dictionary<string, object>> GetNotifications()
    {
        var notifications = new List<Dictionary<string, object>>();

        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand(@"
                SELECT DH.ID,
                       OrderID,
                       UM.FullName AS DealerName,
                       CONVERT(varchar(10), CreatedDate, 105) AS CDate,
                       COUNT(DD.HeaderID) AS TotProducts,
                       SUM(CAST(Qty AS decimal)) AS ProductQty
                FROM tbl_DealersOrderHDR DH
                INNER JOIN tbl_DealersOrderDTLs DD
                    ON DD.HeaderID = DH.ID
                LEFT JOIN tbl_UserMaster UM
                    ON UM.ID = DH.DealerID
                WHERE DH.OrderStatus ='Order Placed'
                GROUP BY DH.ID, OrderID, UM.FullName, CreatedDate,DH.OrderStatus
                ORDER BY DH.ID DESC", con);

                con.Open();

                SqlDataReader dr = cmd.ExecuteReader();
                
                while (dr.Read())
                {
                    notifications.Add(new Dictionary<string, object>
                {
                    { "Id", encrypt(dr["ID"].ToString()) },
                    { "orderId", dr["OrderID"].ToString() },
                    { "dealerName", dr["DealerName"].ToString() },
                    { "totalProducts", dr["TotProducts"].ToString() },
                    { "productQty", dr["ProductQty"].ToString() },
                    { "orderDate", dr["CDate"].ToString() }
                });
                }
            }
        }

        return notifications;
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
}



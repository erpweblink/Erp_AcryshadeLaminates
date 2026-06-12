using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;

/// <summary>
/// Summary description for CommonCls
/// </summary>
public class CommonCls
{
   
    public string Decrypt(string cipherText)
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
    public string encrypt(string encryptString)
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

    public string ActiveCount()
    {
        Cls_Main.Conn_Open();
        string count = "";
        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            SqlCommand cmd = new SqlCommand("SELECT Count(*) FROM tbl_EnquiryData where IsActive=1 AND Sample=1 AND Notiification=0  AND DATEADD(DAY, 3, CAST(SampleDate AS DATE)) <= CAST(GETDATE() AS DATE);", Cls_Main.Conn);
            count = Convert.ToString(cmd.ExecuteScalar());
        }
        else
        {
            SqlCommand cmd = new SqlCommand("SELECT Count(*) FROM tbl_EnquiryData where sessionname='" + HttpContext.Current.Session["UserCode"].ToString() + "'  AND IsActive=1 AND Sample=1 AND Notiification=0  AND DATEADD(DAY, 3, CAST(SampleDate AS DATE)) <= CAST(GETDATE() AS DATE);", Cls_Main.Conn);

            count = Convert.ToString(cmd.ExecuteScalar());
        }
      
        Cls_Main.Conn_Close();
        return count;
    }
    public string ComponentEditRequestCount()
    {
        Cls_Main.Conn_Open();
        string count = "";
        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            SqlCommand cmd = new SqlCommand("SELECT Count(*) FROM  tbl_OutwardEntryHdr where IsEditApproval=1", Cls_Main.Conn);
            count = Convert.ToString(cmd.ExecuteScalar());
        }
        else
        {
            count = "";
        }
        Cls_Main.Conn_Close();
        return count;
    }

    public string PurchaseBillRequestCount()
    {
        Cls_Main.Conn_Open();
        string count = "";
        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            SqlCommand cmd = new SqlCommand("SELECT Count(*) FROM  tblPurchaseBillHdr where IsEditApproval=1", Cls_Main.Conn);
            count = Convert.ToString(cmd.ExecuteScalar());
        }
        else
        {
            count = "";
        }       
        Cls_Main.Conn_Close();
        return count;
    }
    public string ProductRateChangeCount()
    {
        Cls_Main.Conn_Open();
        string count = "";
        if (HttpContext.Current.Session["Role"].ToString() == "Admin")
        {
            SqlCommand cmd = new SqlCommand("select  Count(*) from tbl_CustomerPurchaseOrderHdr AS CPH  INNER JOIN tbl_CustomerPurchaseOrderDtls AS CPO ON CPH.Pono=CPO.Pono  INNER JOIN tbl_ProductMaster AS PM ON PM.Productname=CPO.Productname  WHERE  CPO.Status=1", Cls_Main.Conn);
            count = Convert.ToString(cmd.ExecuteScalar());
        }
        else
        {
            count = "";
        }
        Cls_Main.Conn_Close();
        return count;
    }

     public string ReceiptChangeCount()
  {
      string query;
      int count = 0;

      if (HttpContext.Current.Session["Role"] != null &&
          HttpContext.Current.Session["Role"].ToString() == "Admin")
      {
          query = "SELECT COUNT(*) FROM tblReceiptHdr WHERE IsEditApproval=1";
      }
      else
      {
          query = "SELECT COUNT(*) FROM tblReceiptHdr WHERE IsEditApproval = 2 AND Createdby='"+ HttpContext.Current.Session["UserName"].ToString() + "'";
      }

      DataTable dt = Cls_Main.Read_Table(query);

      if (dt.Rows.Count > 0)
      {
          count = Convert.ToInt32(dt.Rows[0][0]);
      }

      return count.ToString();
  }
    public string GetTotalNotification(string a,string b,  string c, string d,string e)
    {
        int count1 = 0, count2 = 0, count3 = 0 ,count4 = 0, count5 = 0;
        int.TryParse(a, out count1);
        int.TryParse(b, out count2);
        int.TryParse(c, out count3);
        int.TryParse(d, out count4);
        int.TryParse(e, out count5);
        string count = (count1 + count2 + count3 + count4 + count5).ToString();
        return count;
    }
}
using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class DealerMaster : System.Web.UI.Page
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
                //Check if you has access to the page of not
                {
                    string username = Session["ID"].ToString();
                    using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                    {
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'DealerList.aspx'";
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

                if (Request.QueryString["Id"] != null)
                {
                    string ID = objcls.Decrypt(Request.QueryString["Id"].ToString());
                    hdnVal.Value = ID;
                    LoadData(ID);
                }
            }
        }
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_DealerMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "DealerListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtUserFName.Text = dt.Rows[0]["FullName"].ToString();
            txtComName.Text = dt.Rows[0]["CompanyName"].ToString();
            txtEmailID.Text = dt.Rows[0]["EmailId"].ToString();
            txtMobileNo.Text = dt.Rows[0]["MobileNo"].ToString();
            ddlUserType.SelectedValue = dt.Rows[0]["Type"].ToString();
            hdnPass.Value = dt.Rows[0]["LoginPass"].ToString();
            if (ddlUserType.SelectedValue == "Non Authorized")
            {
                RequiredFieldValidator5.Enabled = false;
            }
            else
            {
                RequiredFieldValidator5.Enabled = true;
            }
            txtGstNo.Text = dt.Rows[0]["GstNo"].ToString();
            txtPanCard.Text = dt.Rows[0]["PanCardNo"].ToString();
            txtUANNo.Text = dt.Rows[0]["UANNo"].ToString();
            txtBillAddress.Text = dt.Rows[0]["BillAddress"].ToString();
            txtBillArea.Text = dt.Rows[0]["BillArea"].ToString();
            txtBillPinCode.Text = dt.Rows[0]["BillPinCode"].ToString();
            txtBillState.Text = dt.Rows[0]["BillState"].ToString();
            txtBillCity.Text = dt.Rows[0]["BillCity"].ToString();
            txtBillCountry.Text = dt.Rows[0]["BillCountry"].ToString();
            txtShipAddress.Text = dt.Rows[0]["ShipAddress"].ToString();
            txtShipArea.Text = dt.Rows[0]["ShipArea"].ToString();
            txtShipPinCode.Text = dt.Rows[0]["ShipPinCode"].ToString();
            txtShipCity.Text = dt.Rows[0]["ShipCity"].ToString();
            txtShipState.Text = dt.Rows[0]["ShipState"].ToString();
            txtShipCountry.Text = dt.Rows[0]["ShipCountry"].ToString();
            btnsave.Text = "Update";
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_DealerMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@FullName", SqlDbType.VarChar).Value = txtUserFName.Text;
            cmd.Parameters.Add("@CompanyName", SqlDbType.VarChar).Value = txtComName.Text;
            cmd.Parameters.Add("@MobileNo", SqlDbType.VarChar).Value = txtMobileNo.Text;
            cmd.Parameters.Add("@EmialId", SqlDbType.VarChar).Value = txtEmailID.Text;
            cmd.Parameters.Add("@Password", SqlDbType.VarChar).Value = string.IsNullOrWhiteSpace(hdnPass.Value) ? Generate4DigitPassword() : hdnPass.Value;
            cmd.Parameters.Add("@Type", SqlDbType.VarChar).Value = ddlUserType.SelectedValue;
            cmd.Parameters.Add("@GstNo", SqlDbType.VarChar).Value = txtGstNo.Text;
            cmd.Parameters.Add("@PanCardNo", SqlDbType.VarChar).Value = txtPanCard.Text;
            cmd.Parameters.Add("@UANNo", SqlDbType.VarChar).Value = txtUANNo.Text;
            cmd.Parameters.Add("@BillAddress", SqlDbType.VarChar).Value = txtBillAddress.Text;
            cmd.Parameters.Add("@BillArea", SqlDbType.VarChar).Value = txtBillArea.Text;
            cmd.Parameters.Add("@BillPinCode", SqlDbType.VarChar).Value = txtBillPinCode.Text;
            cmd.Parameters.Add("@BillState", SqlDbType.VarChar).Value = txtBillState.Text;
            cmd.Parameters.Add("@BillCity", SqlDbType.VarChar).Value = txtBillCity.Text;
            cmd.Parameters.Add("@BillCountry", SqlDbType.VarChar).Value = txtBillCountry.Text;
            cmd.Parameters.Add("@ShipAddress", SqlDbType.VarChar).Value = txtShipAddress.Text;
            cmd.Parameters.Add("@ShipArea", SqlDbType.VarChar).Value = txtShipArea.Text;
            cmd.Parameters.Add("@ShipPinCode", SqlDbType.VarChar).Value = txtShipPinCode.Text;
            cmd.Parameters.Add("@ShipState", SqlDbType.VarChar).Value = txtShipState.Text;
            cmd.Parameters.Add("@ShipCity", SqlDbType.VarChar).Value = txtShipCity.Text;
            cmd.Parameters.Add("@ShipCountry", SqlDbType.VarChar).Value = txtShipCountry.Text;
            cmd.Parameters.Add("@UserRole", SqlDbType.VarChar).Value = "Dealer";
            cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();

            if (btnsave.Text == "Update")
            {
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(hdnVal.Value);
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateDealer";
            }
            else
            {
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertDealer";
            }
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            if (btnsave.Text == "Update")
            {
                Session["message"] = "Dealer updated successfully.";
            }
            else
            {
                Session["message"] = "Dealer created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/DealerList.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    public string Generate4DigitPassword()
    {
        Random _random = new Random();
        int number = _random.Next(0, 10000);
        return number.ToString("D4");
    }

    protected void btn_DeList_click(object sender, EventArgs e)
    {
        Response.Redirect("DealerList.aspx");
    }

    protected void check_address_CheckedChanged(object sender, EventArgs e)
    {
        if (check_address.Checked)
        {
            txtShipAddress.Text = txtBillAddress.Text;
            txtShipArea.Text = txtBillArea.Text;
            txtShipPinCode.Text = txtBillPinCode.Text;
            txtShipCity.Text = txtBillCity.Text;
            txtShipState.Text = txtBillState.Text;
            txtShipCountry.Text = txtBillCountry.Text;
        }
        else
        {
            txtShipAddress.Text = "";
            txtShipArea.Text = "";
            txtShipPinCode.Text = "";
            txtShipCity.Text = "";
            txtShipState.Text = "";
            txtShipCountry.Text = "";
        }
    }

    protected void ddlType_Change(object sender, EventArgs e)
    {
        if (ddlUserType.SelectedValue == "Non Authorized")
        {
            RequiredFieldValidator5.Enabled = false;
        }
        else
        {
            RequiredFieldValidator5.Enabled = true;
        }
    }

    protected void txtEmailId_TextChange(object sender, EventArgs e)
    {
        string email = txtEmailID.Text.Trim();
        if (string.IsNullOrWhiteSpace(email))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "alert", "alert('Please enter Email ID.');", true);
            txtEmailID.Focus();
            return;
        }

        string emailPattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

        if (!Regex.IsMatch(email, emailPattern))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "alert", "alert('Please enter valid Email ID.');", true);

            txtEmailID.Text = "";
            txtEmailID.Focus();
            return;
        }

        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_DealerMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CheckEmialId");
        cmd.SelectCommand.Parameters.AddWithValue("@EmialId", txtEmailID.Text.Trim());
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Email ID Already Exist.');", true);
            txtEmailID.Text = "";
            return;
        }
    }

    protected void txtGstNo_TextChange(object sender, EventArgs e)
    {
        System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
        if (!string.IsNullOrWhiteSpace(txtGstNo.Text))
        {
            string InsertGSTNo = txtGstNo.Text.Trim();


            using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                string query = @"SELECT ID FROM tbl_UserMaster WHERE GstNo = @GstNo AND IsDeleted = 0";
                SqlCommand cmds = new SqlCommand(query, cons);
                cmds.Parameters.AddWithValue("@GstNo", InsertGSTNo);
                cons.Open();
                object result = cmds.ExecuteScalar();
                if (result != null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                   "alert", "alert('A company already exists with the entered GST Number.');", true);
                    txtGstNo.Text = "";
                    return;
                }   
            }

            string gstPattern = @"^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$";

            if (!Regex.IsMatch(InsertGSTNo, gstPattern))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('Please enter a valid GST Number.');", true);
                txtGstNo.Text = "";
                return;
            }


            string UserName = ConfigurationManager.AppSettings["UserName"].ToString();
            string Password = ConfigurationManager.AppSettings["Password"].ToString();
            string GSTIN = ConfigurationManager.AppSettings["GSTIN"].ToString();
            string IP_Address = ConfigurationManager.AppSettings["IP_Address"].ToString();
            string E_Invoice_Client_Id = ConfigurationManager.AppSettings["E_Invoice_Client_Id"].ToString();
            string E_Invoice_Client_Secret = ConfigurationManager.AppSettings["E_Invoice_Client_Secret"].ToString();
            string E_Waybill_Client_Id = ConfigurationManager.AppSettings["E_Waybill_Client_Id"].ToString();
            string E_Waybill_Client_Secret = ConfigurationManager.AppSettings["E_Waybill_Client_Secret"].ToString();

            DataTable DT_AuthToken = new DataTable();
            SqlDataAdapter sad_AuthToken = new SqlDataAdapter("SP_AUTH_TOKEN_MASTER", con);
            sad_AuthToken.SelectCommand.CommandType = CommandType.StoredProcedure;
            sad_AuthToken.SelectCommand.Parameters.AddWithValue("@UserName", UserName);
            sad_AuthToken.SelectCommand.Parameters.AddWithValue("@Action", "GetToken");
            sad_AuthToken.Fill(DT_AuthToken);
            if (DT_AuthToken.Rows.Count > 0)
            {
                DateTime Token_Expiry = Convert.ToDateTime(DT_AuthToken.Rows[0]["TokenExpiry"]);
                string _AuthKey = "";
                if (Token_Expiry <= DateTime.Now)
                {
                    _AuthKey = GenerateAuthKey(UserName, Password, GSTIN, IP_Address, E_Invoice_Client_Id, E_Invoice_Client_Secret);
                }
                else
                {
                    _AuthKey = DT_AuthToken.Rows[0]["AuthKey"].ToString();
                }

                if (string.IsNullOrWhiteSpace(_AuthKey))
                    throw new Exception("Auth token generation failed: ");

                string url = "https://api.mastergst.com/einvoice/type/GSTNDETAILS/version/V1_03?param1=" + InsertGSTNo + "&email=erp%40weblinkservices.net";
                WebResponse response;
                WebRequest request = WebRequest.Create(url);

                request.Method = "GET";
                request.Headers.Add("ip_address", IP_Address);
                request.Headers.Add("client_id", E_Invoice_Client_Id);
                request.Headers.Add("client_secret", E_Invoice_Client_Secret);
                request.Headers.Add("username", UserName);
                request.Headers.Add("auth-token", _AuthKey);
                request.Headers.Add("gstin", GSTIN);
                response = request.GetResponse();

                using (Stream dataStream = response.GetResponseStream())
                {
                    StreamReader reader = new StreamReader(dataStream);
                    string responseFromServer = reader.ReadToEnd();

                    var myJsonString = responseFromServer;
                    var jo = JObject.Parse(myJsonString);

                    string Status_Desc = jo["status_desc"].ToString();
                    string Status_CD = jo["status_cd"].ToString();

                    string TradeName = null, Address = null, Area = null, City = null, Status = null, PinCode = null, StateCode = null;
                    if (Status_CD != "0")
                    {
                        TradeName = jo["data"]["TradeName"].ToString();
                        Address = jo["data"]["AddrFlno"].ToString() + " " + jo["data"]["AddrBno"].ToString() + " " + jo["data"]["AddrBnm"].ToString() + " " + jo["data"]["AddrSt"].ToString();
                        Area = jo["data"]["AddrLoc"].ToString();
                        City = jo["data"]["AddrLoc"].ToString();
                        PinCode = jo["data"]["AddrPncd"].ToString();
                        StateCode = jo["data"]["StateCode"].ToString();
                        Status = jo["data"]["Status"].ToString();
                    }

                    if (!string.IsNullOrEmpty(InsertGSTNo) && InsertGSTNo.Length == 15)
                    {
                        txtPanCard.Text = InsertGSTNo.Substring(2, 10);
                    }
                    txtUserFName.Text = TradeName;
                    txtComName.Text = TradeName;
                    txtBillAddress.Text = Address;
                    txtBillArea.Text = Area;
                    txtBillPinCode.Text = PinCode;
                    txtBillCity.Text = City;
                    txtBillState.Text = GetStateNames(Convert.ToInt32(StateCode));
                    txtBillCountry.Text = "India";
                }
            }

        }
        else
        {
            txtUserFName.Text = "";
            txtComName.Text = "";
            txtBillAddress.Text = "";
            txtBillArea.Text = "";
            txtBillPinCode.Text = "";
            txtBillCity.Text = "";
            txtBillState.Text = "";
            txtBillCountry.Text = "";
            txtShipAddress.Text = "";
            txtShipArea.Text = "";
            txtShipPinCode.Text = "";
            txtShipCity.Text = "";
            txtShipState.Text = "";
            txtShipCountry.Text = "";
        }
    }

    protected string GenerateAuthKey(string userName, string password, string GSTIN, string IP_Address, string E_Invoice_Client_Id, string E_Invoice_Client_Secret)
    {

        SqlCommand Cmd;
        string url = "https://api.mastergst.com/einvoice/authenticate?email=erp%40weblinkservices.net";
        WebResponse response;
        WebRequest request = WebRequest.Create(url);

        request.Method = "GET";
        request.Headers.Add("username", userName);
        request.Headers.Add("password", password);
        request.Headers.Add("gstin", GSTIN);
        request.Headers.Add("ip_address", IP_Address);
        request.Headers.Add("client_id", E_Invoice_Client_Id);
        request.Headers.Add("client_secret", E_Invoice_Client_Secret);
        response = request.GetResponse();

        string TokenExpiry = "";
        string Sek = "";
        string ClientId = "";
        string AuthKey = "";

        using (Stream dataStream = response.GetResponseStream())
        {
            StreamReader reader = new StreamReader(dataStream);
            string responseFromServer = reader.ReadToEnd();

            var myJsonString = responseFromServer;
            var jo = JObject.Parse(myJsonString);
            string Status_Desc = jo["status_desc"].ToString();
            string Status_CD = jo["status_cd"].ToString();

            if (Status_CD != "0")
            {
                TokenExpiry = jo["data"]["TokenExpiry"].ToString();
                Sek = jo["data"]["Sek"].ToString();
                ClientId = jo["data"]["ClientId"].ToString();
                AuthKey = jo["data"]["AuthToken"].ToString();

                con.Open();
                Cmd = new SqlCommand("SP_AUTH_TOKEN_MASTER", con);
                Cmd.CommandType = CommandType.StoredProcedure;
                Cmd.Parameters.AddWithValue("@Action", "DeleteOldToken");
                Cmd.ExecuteNonQuery();


                Cmd = new SqlCommand("SP_AUTH_TOKEN_MASTER", con);
                Cmd.CommandType = CommandType.StoredProcedure;
                Cmd.Parameters.AddWithValue("@Action", "UpsertToken");
                Cmd.Parameters.AddWithValue("@UserName", userName);
                Cmd.Parameters.AddWithValue("@TokenExpiry", Convert.ToDateTime(TokenExpiry).AddMinutes(-45));
                Cmd.Parameters.AddWithValue("@Sek", Sek);
                Cmd.Parameters.AddWithValue("@ClientId", ClientId);
                Cmd.Parameters.AddWithValue("@AuthToken", AuthKey);
                Cmd.ExecuteNonQuery();
                con.Close();
            }
        }

        return AuthKey;
    }

    protected string GetStateNames(int Code)
    {
        if (string.IsNullOrWhiteSpace(Code.ToString()))
            return "Unknown";

        switch (Code)
        {
            case 1: return "Jammu and Kashmir";
            case 2: return "Himachal Pradesh";
            case 3: return "Punjab";
            case 4: return "Chandigarh";
            case 5: return "Uttarakhand";
            case 6: return "Haryana";
            case 7: return "Delhi";
            case 8: return "Rajasthan";
            case 9: return "Uttar Pradesh";
            case 10: return "Bihar";
            case 11: return "Sikkim";
            case 12: return "Arunachal Pradesh";
            case 13: return "Nagaland";
            case 14: return "Manipur";
            case 15: return "Mizoram";
            case 16: return "Tripura";
            case 17: return "Meghalaya";
            case 18: return "Assam";
            case 19: return "West Bengal";
            case 20: return "Jharkhand";
            case 21: return "Odisha";
            case 22: return "Chhattisgarh";
            case 23: return "Madhya Pradesh";
            case 24: return "Gujarat";
            case 25: return "Daman and Diu";
            case 26: return "Dadra and Nagar Haveli";
            case 27: return "Maharashtra";
            case 28: return "Andhra Pradesh";
            case 29: return "Karnataka";
            case 30: return "Goa";
            case 31: return "Lakshadweep";
            case 32: return "Kerala";
            case 33: return "Tamil Nadu";
            case 34: return "Puducherry";
            case 35: return "Andaman and Nicobar Islands";
            case 36: return "Telangana";
            case 37: return "Ladakh";
            default: return "Unknown";
        }
    }
}



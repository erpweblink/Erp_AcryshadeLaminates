using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;


public partial class CompanyMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'CompanyList.aspx'";
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
        SqlDataAdapter cmd = new SqlDataAdapter("SP_CompanyMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "MainCompanyListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtCompanyName.Text = dt.Rows[0]["CompanyName"].ToString();
            txtOwnerName.Text = dt.Rows[0]["OwnerName"].ToString();
            ddlCompanyOrigin.SelectedValue = dt.Rows[0]["CompanyOrigin"].ToString();
            txtCompanyEmialId.Text = dt.Rows[0]["CompanyEmialId"].ToString();
            txtCompanyPanCard.Text = dt.Rows[0]["CompanyPanCard"].ToString();
            txtPaymentTerms.Text = dt.Rows[0]["PaymentTerms"].ToString();
            txtUDYAMNo.Text = dt.Rows[0]["UDYAMNo"].ToString();
            txtWebsiteLink.Text = dt.Rows[0]["WebsiteLink"].ToString();

            DataTable dts = new DataTable();
            SqlDataAdapter cmds = new SqlDataAdapter("SP_CompanyMaster", con);
            cmds.SelectCommand.CommandType = CommandType.StoredProcedure;
            cmds.SelectCommand.Parameters.AddWithValue("@SP_Action", "CompDetailsListById");
            cmds.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
            cmds.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            cmds.Fill(dts);
            if (dts.Rows.Count > 0)
            {
                DataTable dtss = new DataTable();
                SqlDataAdapter cmdss = new SqlDataAdapter("SP_CompanyMaster", con);
                cmdss.SelectCommand.CommandType = CommandType.StoredProcedure;
                cmdss.SelectCommand.Parameters.AddWithValue("@SP_Action", "CompCntDetailsListById");
                cmdss.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
                cmdss.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmdss.Fill(dtss);

                JavaScriptSerializer js = new JavaScriptSerializer();

                var result = new
                {
                    Addresses = DataTableToList(dts),
                    Contacts = DataTableToList(dtss)
                };

                string json = js.Serialize(result);

                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "LoadCompany",
                    "loadCompanyData(" + json + ");",
                    true);

            }
            btnsave.Text = "Update";
        }
    }

    private List<Dictionary<string, object>> DataTableToList(DataTable dt)
    {
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

        return rows;
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            // MASTER VALUES
            string CompanyName = txtCompanyName.Text.Trim();
            string OwnerName = txtOwnerName.Text.Trim();
            string CompanyOrigin = ddlCompanyOrigin.SelectedValue;
            string CompanyEmialId = txtCompanyEmialId.Text.Trim();
            string CompanyPanCard = txtCompanyPanCard.Text.Trim();
            string PaymentTerms = txtPaymentTerms.Text.Trim();
            string UDYAMNo = txtUDYAMNo.Text.Trim();
            string WebsiteLink = txtWebsiteLink.Text.Trim();
            int Id = 0;

            // Billing DETAIL VALUES
            string[] GSTNo = Request.Form.GetValues("GSTNo[]");
            string[] PinCode = Request.Form.GetValues("PinCode[]");
            string[] Country = Request.Form.GetValues("Country[]");
            string[] State = Request.Form.GetValues("State[]");
            string[] City = Request.Form.GetValues("City[]");
            string[] Address = Request.Form.GetValues("Address[]");
            string[] Area = Request.Form.GetValues("Area[]");

            //Shipping Details Value
            string[] SGSTNo = Request.Form.GetValues("SGSTNo[]");
            string[] SPinCode = Request.Form.GetValues("SPinCode[]");
            string[] SCountry = Request.Form.GetValues("SCountry[]");
            string[] SState = Request.Form.GetValues("SState[]");
            string[] SCity = Request.Form.GetValues("SCity[]");
            string[] SAddress = Request.Form.GetValues("SAddress[]");
            string[] SArea = Request.Form.GetValues("SArea[]");


            // Contact Details Value
            string[] Cname = Request.Form.GetValues("Cname[]");
            string[] CmobNo = Request.Form.GetValues("CmobNo[]");
            string[] CemialId = Request.Form.GetValues("CemialId[]");
            string[] Cdept = Request.Form.GetValues("Cdept[]");
            string[] Cdesig = Request.Form.GetValues("Cdesig[]");

            bool hasBillingData = false;
            for (int i = 0; i < Address.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(PinCode[i]) &&
                   string.IsNullOrWhiteSpace(Address[i]))
                {
                    hasBillingData = true;
                    break;
                }
            }

            if (hasBillingData)
            {
                ScriptManager.RegisterStartupScript(
                       this,
                       this.GetType(),
                       "alert",
                       "alert('Please add at least one billing information');",
                       true
                   );
                return;
            }

            con.Open();

            using (SqlCommand cmd = new SqlCommand("SP_CompanyMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // MASTER DATA
                cmd.Parameters.AddWithValue("@CompanyName", CompanyName);
                cmd.Parameters.AddWithValue("@OwnerName", OwnerName);
                cmd.Parameters.AddWithValue("@CompanyOrigin", CompanyOrigin);
                cmd.Parameters.AddWithValue("@CompanyEmialId", CompanyEmialId);
                cmd.Parameters.AddWithValue("@CompanyPanCard", CompanyPanCard);
                cmd.Parameters.AddWithValue("@PaymentTerms", PaymentTerms);
                cmd.Parameters.AddWithValue("@UDYAMNo", UDYAMNo);
                cmd.Parameters.AddWithValue("@WebsiteLink", WebsiteLink);
                cmd.Parameters.AddWithValue("@ActionBy", Session["ID"].ToString());
                if (btnsave.Text == "Update")
                {
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.AddWithValue("@SP_Action", "UpdateMainCompany");
                }
                else
                {
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertMainCompany");
                }
                cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);
            }


            if (btnsave.Text == "Update")
            {
                using (SqlCommand cmd = new SqlCommand("SP_CompanyMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "DeleteCompDetails");
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
                Id = Convert.ToInt32(hdnVal.Value);
            }

            // Loop for company details 
            for (int i = 0; i < SAddress.Length; i++)
            {
                string billGST = null, billPin = null, billCountry = null, billState = null, billCity = null, billAddress = null, billArea = null;
                if (Address.Length >= i +1)
                {
                     billGST = GSTNo[i];
                     billPin = PinCode[i];
                     billCountry = Country[i];
                     billState = State[i];
                     billCity = City[i];
                     billAddress = Address[i];
                     billArea = Area[i];
                }

                using (SqlCommand cmd = new SqlCommand("SP_CompanyMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertCompDetails");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);

                    cmd.Parameters.AddWithValue("@BillGSTNo", billGST);
                    cmd.Parameters.AddWithValue("@BillPinCode", billPin);
                    cmd.Parameters.AddWithValue("@BillCountry", billCountry);
                    cmd.Parameters.AddWithValue("@BillState", billState);
                    cmd.Parameters.AddWithValue("@BillCity", billCity);
                    cmd.Parameters.AddWithValue("@BillAddress", billAddress);
                    cmd.Parameters.AddWithValue("@BillArea", billArea);

                    cmd.Parameters.AddWithValue("@ShipGSTNo", string.IsNullOrWhiteSpace(SGSTNo[i].Trim()) ? "" : SGSTNo[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipPinCode", string.IsNullOrWhiteSpace(SPinCode[i].Trim()) ? "" : SPinCode[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipCountry", string.IsNullOrWhiteSpace(SCountry[i].Trim()) ? "" : SCountry[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipState", string.IsNullOrWhiteSpace(SState[i].Trim()) ? "" : SState[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipCity", string.IsNullOrWhiteSpace(SCity[i].Trim()) ? "" : SCity[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipAddress", string.IsNullOrWhiteSpace(SAddress[i].Trim()) ? "" : SAddress[i].Trim());
                    cmd.Parameters.AddWithValue("@ShipArea", string.IsNullOrWhiteSpace(SArea[i].Trim()) ? "" : SArea[i].Trim());

                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
            }


            if (btnsave.Text == "Update")
            {
                using (SqlCommand cmd = new SqlCommand("SP_CompanyMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "DeleteCompCntDetails");
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
                Id = Convert.ToInt32(hdnVal.Value);
            }

            // Loop for contact details
            for (int i = 0; i < Cname.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(Cname[i]) &&
                   string.IsNullOrWhiteSpace(CmobNo[i]) &&
                   string.IsNullOrWhiteSpace(CemialId[i]) &&
                   string.IsNullOrWhiteSpace(Cdept[i]) &&
                   string.IsNullOrWhiteSpace(Cdesig[i]))
                {
                    continue;
                }

                using (SqlCommand cmd = new SqlCommand("SP_CompanyMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertCompCntDetails");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);

                    cmd.Parameters.AddWithValue("@FName", string.IsNullOrWhiteSpace(Cname[i].Trim()) ? "" : Cname[i].Trim());
                    cmd.Parameters.AddWithValue("@MobileNo", string.IsNullOrWhiteSpace(CmobNo[i].Trim()) ? "" : CmobNo[i].Trim());
                    cmd.Parameters.AddWithValue("@EmialID", string.IsNullOrWhiteSpace(CemialId[i].Trim()) ? "" : CemialId[i].Trim());
                    cmd.Parameters.AddWithValue("@Department", string.IsNullOrWhiteSpace(Cdept[i].Trim()) ? "" : Cdept[i].Trim());
                    cmd.Parameters.AddWithValue("@Designation", string.IsNullOrWhiteSpace(Cdesig[i].Trim()) ? "" : Cdesig[i].Trim());

                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
            }


            con.Close();
            if (btnsave.Text == "Update")
            {
                Session["message"] = "Company updated successfully.";
            }
            else
            {
                Session["message"] = "Company created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/CompanyList.aspx";

            Response.Redirect("/Alerts.aspx");
        }
        catch (Exception)
        {
            con.Close();
            throw;
        }
    }

    protected void btn_DeList_click(object sender, EventArgs e)
    {
        Response.Redirect("CompanyList.aspx");
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetCompanyNameList(string prefixText, int count)
    {
        return AutoFillGetCompanyNameList(prefixText);
    }

    public static List<string> AutoFillGetCompanyNameList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                CompanyName
            FROM tbl_CompanyMain
            WHERE CompanyName LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["CompanyName"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }

}



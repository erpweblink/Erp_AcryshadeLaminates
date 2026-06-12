using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;

public partial class WorkOrderMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WorkOrderList.aspx'";
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


                txtworkorderdate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtworkorderdate.Enabled = false;   

                if (Request.QueryString["Id"] != null)
                {
                    string ID = objcls.Decrypt(Request.QueryString["Id"].ToString());
                    hdnVal.Value = ID;
                    LoadData(ID);
                }
                else
                {
                   // txtworkorderdate.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");
                }
            }
        }
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_WorkOrderMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "WoHdrListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            divtxtbox.Visible = true;
            divdropdown.Visible = false;
            RequiredFieldValidator4.Enabled = false;
            RequiredFieldValidator6.Enabled = true;

            txttallyref.Text = dt.Rows[0]["TallyRefNo"].ToString();
            txttallyref.ReadOnly = true;

            DateTime dt1 = Convert.ToDateTime(dt.Rows[0]["WorkOrderDate"]);
            txtworkorderdate.Text = dt1.ToString("yyyy-MM-dd");

            txtDealerName.Text = dt.Rows[0]["Dealer"].ToString();
            txtCustName.Text = dt.Rows[0]["CustomerName"].ToString();
            txtrefno.Text = dt.Rows[0]["CustomerRefNo"].ToString();
            txtBillingAddress.Text = dt.Rows[0]["BillingAddress"].ToString();
            txtBillGst.Text = dt.Rows[0]["BillingGstNo"].ToString();
            txtShipAddress.Text = dt.Rows[0]["ShippingAddress"].ToString();
            txtShipGst.Text = dt.Rows[0]["ShippingGstNo"].ToString();
            txtBillPinCode.Text = dt.Rows[0]["BillingPincode"].ToString();
            txtShipPinCode.Text = dt.Rows[0]["ShippingPincode"].ToString();

            DateTime dt2 = Convert.ToDateTime(dt.Rows[0]["DeliveryDate"]);
            txtDeliveryDate.Text = dt2.ToString("yyyy-MM-dd");

            DataTable dts = new DataTable();
            SqlDataAdapter cmds = new SqlDataAdapter("SP_WorkOrderMaster", con);
            cmds.SelectCommand.CommandType = CommandType.StoredProcedure;
            cmds.SelectCommand.Parameters.AddWithValue("@SP_Action", "WODTLSListById");
            cmds.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
            cmds.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            cmds.Fill(dts);
            if (dts.Rows.Count > 0)
            {
                JavaScriptSerializer js = new JavaScriptSerializer();

                List<Dictionary<string, object>> rows =
                    new List<Dictionary<string, object>>();

                foreach (DataRow dr in dts.Rows)
                {
                    Dictionary<string, object> row =
                        new Dictionary<string, object>();

                    foreach (DataColumn col in dts.Columns)
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
            btnsave.Text = "Update";
        }
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            // MASTER VALUES
            string tallyref = txttallyref.Text.Trim().ToUpper();
            DateTime workorderdate = Convert.ToDateTime(txtworkorderdate.Text);
            string DealerName = txtDealerName.Text.Trim();
            string CustName = txtCustName.Text.Trim();
            string refno = txtrefno.Text.Trim();
            string BillingAddress = txtBillingAddress.Text.Trim();
            string ShipAddress = string.IsNullOrWhiteSpace(hdnShipAddressId.Value.Trim()) ? txtShipAddress.Text.Trim() : hdnShipAddressId.Value.Trim();
            string BillGst = txtBillGst.Text.Trim();
            string ShipGst = txtShipGst.Text.Trim();
            string BillPinCode = txtBillPinCode.Text.Trim();
            string ShipPinCode = txtShipPinCode.Text.Trim();
            DateTime DeliveryDate = Convert.ToDateTime(txtDeliveryDate.Text);
            int Id = 0;

            // DETAIL VALUES
            string[] ProductId = Request.Form.GetValues("ProductId[]");
            string[] ProductName = Request.Form.GetValues("ProductName[]");
            string[] SheetNo = Request.Form.GetValues("SheetNo[]");
            string[] Type = Request.Form.GetValues("Type[]");
            string[] Description = Request.Form.GetValues("Description[]");
            string[] Size = Request.Form.GetValues("Size[]");
            string[] Qty = Request.Form.GetValues("Qty[]");
            string[] SqFeet = Request.Form.GetValues("SqFeet[]");
            string[] Unit = Request.Form.GetValues("Unit[]");
            string[] ProdImageName = Request.Form.GetValues("ProdImageName[]");

            HttpFileCollection files = Request.Files;


            bool hasBillingData = false;
            for (int i = 0; i < ProductName.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(ProductName[i]) &&
                   string.IsNullOrWhiteSpace(SheetNo[i]) &&
                   string.IsNullOrWhiteSpace(Description[i]) &&
                   string.IsNullOrWhiteSpace(Size[i]) &&
                   string.IsNullOrWhiteSpace(Qty[i]) &&
                   string.IsNullOrWhiteSpace(Unit[i]))
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
                       "alert('Please add atleast one Product');",
                       true
                   );
                return;
            }

            con.Open();

            using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // MASTER DATA
                cmd.Parameters.AddWithValue("@TallyRefNo", tallyref);
                cmd.Parameters.AddWithValue("@WorkOrderDate", workorderdate);
                cmd.Parameters.AddWithValue("@Dealer", DealerName);
                cmd.Parameters.AddWithValue("@CustomerName", CustName);
                cmd.Parameters.AddWithValue("@CustomerRefNo", refno);
                cmd.Parameters.AddWithValue("@BillingAddress", BillingAddress);
                cmd.Parameters.AddWithValue("@ShippingAddress", ShipAddress);
                cmd.Parameters.AddWithValue("@BillingGstNo", BillGst);
                cmd.Parameters.AddWithValue("@ShippingGstNo", ShipGst);
                cmd.Parameters.AddWithValue("@BillingPincode", BillPinCode);
                cmd.Parameters.AddWithValue("@ShippingPincode", ShipPinCode);
                cmd.Parameters.AddWithValue("@DeliveryDate", DeliveryDate);
                cmd.Parameters.AddWithValue("@ActionBy", Session["ID"].ToString());


                // IMAGE SAVE
                if (FileMCImage.HasFile)
                {
                    string Filenamenew = FileMCImage.FileName;
                    string codenew = Guid.NewGuid().ToString();

                    string folderPath = Server.MapPath("~/Content/WOAttachedFiles/");

                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileName = codenew + "_" + Filenamenew;
                    string fullPath = Path.Combine(folderPath, fileName);

                    FileMCImage.SaveAs(fullPath);

                    cmd.Parameters.AddWithValue("@AttachmentPath",
                        "~/WOAttachedFiles/" + fileName);

                }
                else
                {
                    DataTable dtImage = new DataTable();

                    SqlDataAdapter da = new SqlDataAdapter(
                        "SELECT AttachmentPath FROM tbl_WorkOrderHdr WHERE Id=@Id",
                        con);

                    da.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(string.IsNullOrWhiteSpace(hdnVal.Value) ? "0" : hdnVal.Value));

                    da.Fill(dtImage);

                    if (dtImage.Rows.Count > 0)
                    {
                        cmd.Parameters.AddWithValue("@AttachmentPath", dtImage.Rows[0]["AttachmentPath"]);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@AttachmentPath", DBNull.Value);
                    }
                }


                if (btnsave.Text == "Update")
                {
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.AddWithValue("@SP_Action", "UpdateWoHdr");
                }
                else
                {
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertWoHdr");
                }
                cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);
            }


            if (btnsave.Text == "Update")
            {
                using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "DeleteWODTLS");
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
                Id = Convert.ToInt32(hdnVal.Value);
            }

            int fileIndex = 1;
            // LOOP THROUGH ALL ROWS
            for (int i = 0; i < ProductName.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(ProductName[i]))
                {
                    continue;
                }

                using (SqlCommand cmd = new SqlCommand("SP_WorkOrderMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertWODTLS");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);
                    cmd.Parameters.AddWithValue("@ProductId", string.IsNullOrWhiteSpace(ProductId[i]) ? "" : ProductId[i]);
                    cmd.Parameters.AddWithValue("@ProductName", string.IsNullOrWhiteSpace(ProductName[i]) ? "" : ProductName[i]);
                    cmd.Parameters.AddWithValue("@PartNo", string.IsNullOrWhiteSpace(SheetNo[i]) ? "0" : SheetNo[i]);
                    cmd.Parameters.AddWithValue("@Type", string.IsNullOrWhiteSpace(Type[i]) ? "0" : Type[i]);
                    cmd.Parameters.AddWithValue("@Description", string.IsNullOrWhiteSpace(Description[i]) ? "" : Description[i]);
                    cmd.Parameters.AddWithValue("@Size", string.IsNullOrWhiteSpace(Size[i]) ? "0" : Size[i]);
                    cmd.Parameters.AddWithValue("@Qty", string.IsNullOrWhiteSpace(Qty[i]) ? "0" : Qty[i]);
                    cmd.Parameters.AddWithValue("@SqFeet", string.IsNullOrWhiteSpace(SqFeet[i]) ? "0" : SqFeet[i]);
                    cmd.Parameters.AddWithValue("@Unit", string.IsNullOrWhiteSpace(Unit[i]) ? "" : Unit[i]);

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

                        file.SaveAs(Path.Combine(folderPath, fileName));

                        cmd.Parameters.AddWithValue(
                            "@UploadedImage",
                            "~/WOCustomProducts/" + fileName
                        );
                    }
                    else
                    {
                        if (!string.IsNullOrWhiteSpace(ProdImageName[i]) && ProdImageName[i] != "null")
                        {
                            cmd.Parameters.AddWithValue("@UploadedImage", ProdImageName[i]);
                        }
                    }


                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
            }

            con.Close();
            if (btnsave.Text == "Update")
            {
                Session["message"] = "Work Order updated successfully.";
            }
            else
            {
                Session["message"] = "Work Order created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/WorkOrderList.aspx";

            Response.Redirect("/Alerts.aspx");
        }
        catch (Exception)
        {
            con.Close();
            throw;
        }
    }

    protected void btnDeList_Click(object sender, EventArgs e)
    {
        Response.Redirect("WorkOrderList.aspx");
    }

    [ScriptMethod]
    [WebMethod]
    public static List<string> GetDealerNameList(string prefixText, int count)
    {
        return AutoFillGetDealerNameList(prefixText);
    }

    public static List<string> AutoFillGetDealerNameList(string prefixText)
    {
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT ID, FullName
            FROM tbl_UserMaster
            WHERE Type='Authorized'
              AND UserRole='Dealers'
              AND IsDeleted=0
              AND FullName LIKE '%' + @Search + '%'";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string dealerName = dr["FullName"].ToString();
                string dealerId = dr["ID"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                        dealerName,
                        dealerId
                    )
                );
            }
        }

        return items;
    }

    [WebMethod]
    public static List<string> GetDealersInfo(string dealerId)
    {
        List<string> list = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT BillAddress,BillPinCode,GstNo,ShipAddress,ShipPinCode
                         FROM tbl_UserMaster
                         WHERE ID=@dealerId";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@dealerId", dealerId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                list.Add(dr["BillAddress"].ToString());
                list.Add(dr["BillPinCode"].ToString());
                list.Add(dr["GstNo"].ToString());
                list.Add(dr["ShipAddress"].ToString());
                list.Add(dr["ShipPinCode"].ToString());
            }
        }

        return list;
    }

    [ScriptMethod]
    [WebMethod]
    public static List<string> GetCustNameList(string prefixText, int count, string contextKey)
    {
        return AutoFillGetCustNameList(prefixText, contextKey);
    }

    public static List<string> AutoFillGetCustNameList(string prefixText, string dealerId)
    {
        if (dealerId == null)
        {
            return null;
        }
        List<string> items = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"
            SELECT DISTINCT ID,CompanyName
            FROM tbl_CompanyMain
            WHERE IsDeleted=0
            AND CompanyName LIKE '%' + @Search + '%' --CreatedBy = @Id AND";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);
            cmd.Parameters.AddWithValue("@Id", dealerId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string companyName = dr["CompanyName"].ToString();
                string companyId = dr["ID"].ToString();

                items.Add(
                    AutoCompleteExtender.CreateAutoCompleteItem(
                       companyName,
                       companyId
                    )
                );
            }
        }

        return items;
    }

    [WebMethod]
    public static List<string> GetShippingAddresses(string companyId)
    {
        List<string> list = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT ID,ShipAddress
                         FROM tbl_CompanyDetails
                         WHERE HeaderID=@CompanyID";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@CompanyID", companyId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                list.Add(dr["ID"] + "|" + dr["ShipAddress"]);
            }
        }

        return list;
    }

    [WebMethod]
    public static List<string> GetShippingDetails(string shippingId)
    {
        List<string> list = new List<string>();

        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT ShipAddress,ShipPinCode,
                                ShipGSTNo
                         FROM tbl_CompanyDetails
                         WHERE ID = @shippingId";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@shippingId", shippingId);

            con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                list.Add(
                    dr["ShipAddress"].ToString() + "|" +
                    dr["ShipPinCode"].ToString() + "|" +
                    dr["ShipGSTNo"].ToString()
                );
            }
        }

        return list;
    }

    [WebMethod]
    public static object GetProductAutoComplete(string prefixText)
    {
        var list = new List<object>();

        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            string query = @"
                SELECT TOP 20
                       ID,
                       Productname,
                       PartNo,
                       Size
                FROM tbl_prodcutmaster
                WHERE Productname LIKE '%' + @Search + '%'
                  AND isdeleted = 0 AND isActive = 1
                ORDER BY Productname";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Search", prefixText);

            con.Open();

            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    list.Add(new
                    {
                        ProductId = Convert.ToInt32(dr["ID"]),
                        ProductName = dr["Productname"].ToString(),
                        PartNo = dr["PartNo"].ToString(),
                        Size = dr["Size"].ToString()
                    });
                }
            }
        }

        return list;
    }

    [WebMethod]
    public static object SaveProductMaster(string ProductName, string ItemCode, string Size)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                SqlCommand checkCmd = new SqlCommand(
                    @"SELECT COUNT(*) 
                  FROM tbl_ProdcutMaster
                  WHERE UPPER(REPLACE(LTRIM(RTRIM(ProductName)), ' ', '')) = UPPER(REPLACE(LTRIM(RTRIM(@ProductName)), ' ', ''))", con);

                checkCmd.Parameters.AddWithValue("@ProductName", ProductName);

                int count = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (count == 0)
                {
                    SqlCommand insertCmd = new SqlCommand(
                        @"INSERT INTO tbl_ProdcutMaster
                      (Productcode,Productname,PartNo,Size,IsActive,IsDeleted,CreatedBy,CreatedOn)
                      VALUES
                      ([dbo].[FN_ProductNo](),@ProductName,@ItemCode,@Size,1,0,@ActionBy,GETDATE())", con);

                    insertCmd.Parameters.AddWithValue("@ProductName", ProductName);
                    insertCmd.Parameters.AddWithValue("@ItemCode", ItemCode);
                    insertCmd.Parameters.AddWithValue("@Size", Size);
                    insertCmd.Parameters.AddWithValue("@ActionBy", HttpContext.Current.Session["ID"].ToString());

                    insertCmd.ExecuteNonQuery();
                    return "Success";
                }
            }

            return "No";
        }
        catch (Exception)
        {
            throw;
        }
    }

    protected void txttallyref_TextChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(txttallyref.Text.Trim()))
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                con.Open();

                SqlCommand checkCmd = new SqlCommand(@"SELECT COUNT(*) FROM tbl_WorkOrderHdr
                  WHERE IsDeleted = 0 AND UPPER(REPLACE(LTRIM(RTRIM(TallyRefNo)), ' ', '')) = UPPER(REPLACE(LTRIM(RTRIM(@TallyRef)), ' ', ''))", con);
                checkCmd.Parameters.AddWithValue("@TallyRef", txttallyref.Text.Trim());

                int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                if (count != 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Tally Referance Number is already exists..');", true);
                    txttallyref.Text = "";
                }
            }
        }

    }
}


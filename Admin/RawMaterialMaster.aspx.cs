using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;


public partial class RawMaterialMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'RawMaterialList.aspx'";
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
        SqlDataAdapter cmd = new SqlDataAdapter("SP_RawMaterialMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "RawMatHDRListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtSupplierName.Text = dt.Rows[0]["SupplierName"].ToString();
            txtPurchaseNo.Text = dt.Rows[0]["PurchaseNo"].ToString();
            DateTime date = Convert.ToDateTime(dt.Rows[0]["PurchaseDate"]);
            txtPurchaseDate.Text = date.ToString("yyyy-MM-dd");

            DataTable dts = new DataTable();
            SqlDataAdapter cmds = new SqlDataAdapter("SP_RawMaterialMaster", con);
            cmds.SelectCommand.CommandType = CommandType.StoredProcedure;
            cmds.SelectCommand.Parameters.AddWithValue("@SP_Action", "RawMatDTLSListById");
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
                    "LoadMaterials",
                    "loadRawMaterialData(" + json + ");",
                    true);

            }
            btnsave.Text = "Update";
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            // MASTER VALUES
            string SupplierName = txtSupplierName.Text;
            string PurchaseNo = txtPurchaseNo.Text;
            string PurchaseDate = txtPurchaseDate.Text;
            int Id = 0;

            // DETAIL VALUES
            string[] MaterialName = Request.Form.GetValues("RawMaterialName[]");
            string[] MaterialCode = Request.Form.GetValues("RawMaterialCode[]");
            string[] Category = Request.Form.GetValues("RawMaterialCategory[]");
            string[] Description = Request.Form.GetValues("RawMaterialDesc[]");
            string[] Qty = Request.Form.GetValues("RawMaterialQty[]");
            string[] Unit = Request.Form.GetValues("Unit[]");
;

            bool hasBillingData = false;
            for (int i = 0; i < MaterialName.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(MaterialName[i]) &&
                   string.IsNullOrWhiteSpace(MaterialCode[i]) &&
                   string.IsNullOrWhiteSpace(Category[i]) &&
                   string.IsNullOrWhiteSpace(Description[i]) &&
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
                       "alert('Please add atleast one Raw Material');",
                       true
                   );
                return;
            }


            con.Open();


            using (SqlCommand cmd = new SqlCommand("SP_RawMaterialMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // MASTER DATA
                cmd.Parameters.AddWithValue("@SupplierName", SupplierName);
                cmd.Parameters.AddWithValue("@PurchaseNo", PurchaseNo);
                cmd.Parameters.AddWithValue("@PurchaseDate", PurchaseDate);
                cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();
                if (btnsave.Text == "Update")
                {
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.AddWithValue("@SP_Action", "UpdateRawMatHDR");
                }
                else
                {
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertRawMatHDR");
                }
                cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                cmd.ExecuteNonQuery();
                Id = Convert.ToInt32(cmd.Parameters["@Result"].Value);
            }


            if (btnsave.Text == "Update")
            {
                using (SqlCommand cmd = new SqlCommand("SP_RawMaterialMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "DeleteRawMatDTLS");
                    cmd.Parameters.AddWithValue("@Id", hdnVal.Value);
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
                Id = Convert.ToInt32(hdnVal.Value);
            }

            // LOOP THROUGH ALL ROWS
            for (int i = 0; i < MaterialName.Length; i++)
            {
                if (string.IsNullOrWhiteSpace(MaterialName[i]) &&
                   string.IsNullOrWhiteSpace(MaterialCode[i]) &&
                   string.IsNullOrWhiteSpace(Category[i]) &&
                   string.IsNullOrWhiteSpace(Description[i]) &&
                   string.IsNullOrWhiteSpace(Qty[i]) &&
                   string.IsNullOrWhiteSpace(Unit[i]))
                {
                    continue;
                }

                using (SqlCommand cmd = new SqlCommand("SP_RawMaterialMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SP_Action", "InsertRawMatDTLS");
                    cmd.Parameters.AddWithValue("@HeaderId", Id);
                    cmd.Parameters.AddWithValue("@RawMaterialName", string.IsNullOrWhiteSpace(MaterialName[i]) ? "Not Added" : MaterialName[i]);
                    cmd.Parameters.AddWithValue("@RawMaterialCode", string.IsNullOrWhiteSpace(MaterialCode[i]) ? "Not Added" : MaterialCode[i]);
                    cmd.Parameters.AddWithValue("@RawMaterialCategory", string.IsNullOrWhiteSpace(Category[i]) ? "" : Category[i]);
                    cmd.Parameters.AddWithValue("@RawMaterialDesc", string.IsNullOrWhiteSpace(Description[i]) ? "Not Added" : Description[i]);
                    cmd.Parameters.AddWithValue("@RawMaterialQty", string.IsNullOrWhiteSpace(Qty[i]) ? "0" : Qty[i]);
                    cmd.Parameters.AddWithValue("@Unit", string.IsNullOrWhiteSpace(Unit[i]) ? "" : Unit[i]);
                    cmd.Parameters.AddWithValue("@PerQtyRate","0" );
                    cmd.Parameters.AddWithValue("@GstPercentage","0");
                    cmd.Parameters.AddWithValue("@GstAmount", "0");
                    cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                }
            }

            con.Close();
            if (btnsave.Text == "Update")
            {
                Session["message"] = "Raw Material updated successfully.";
            }
            else
            {
                Session["message"] = "Raw Material saved successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/RawMaterialList.aspx";

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
        Response.Redirect("RawMaterialList.aspx");
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetSupplierNameList(string prefixText, int count)
    {
        return AutoFillGetSupplierNameList(prefixText);
    }

    public static List<string> AutoFillGetSupplierNameList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                SupplierName
            FROM tbl_RawMaterial_HDR
            WHERE SupplierName LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["SupplierName"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }


    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetPurchaseNoList(string prefixText, int count)
    {
        return AutoFillGetPurchaseNoList(prefixText);
    }

    public static List<string> AutoFillGetPurchaseNoList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                PurchaseNo
            FROM tbl_RawMaterial_HDR
            WHERE PurchaseNo LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["PurchaseNo"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }

}



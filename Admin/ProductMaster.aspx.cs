using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Services;
using System.Web.Services;

public partial class Admin_ProductMaster : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserCode"] == null)
        {
            Response.Redirect("../Login.aspx");
        }
        if (!IsPostBack)
        {
            //Check if you has access to the page of not
            {
                string username = Session["ID"].ToString();
                using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                {
                    string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'ProductList.aspx'";
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
            GetCode();

            string encryptedId = Request.QueryString["Id"];

            if (!string.IsNullOrEmpty(encryptedId))
            {
                string ID = objcls.Decrypt(encryptedId);

                hdnVal.Value = ID;

                LoadData(ID);
            }
        }
    }

    protected void GetCode()
    {
        using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            string query = @"SELECT [dbo].[FN_ProductNo]() AS ProductNo ";
            SqlCommand cmds = new SqlCommand(query, cons);
            cons.Open();
            object result = cmds.ExecuteScalar();
            if (result == null || result.ToString() != "True")
            {
                txtproductcode.Text = result.ToString();
            }
        }
    }

    protected void btnDeList_Click(object sender, EventArgs e)
    {
        Response.Redirect("ProductList.aspx");
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand("SP_ProductsMaster", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Productcode", SqlDbType.VarChar).Value = txtproductcode.Text.Trim();
                cmd.Parameters.Add("@Productname", SqlDbType.VarChar).Value = txtproductname.Text.Trim();
                cmd.Parameters.Add("@Thickness", SqlDbType.VarChar).Value = txtThickness.Text.Trim();
                cmd.Parameters.Add("@Size", SqlDbType.VarChar).Value = ddlSize.SelectedValue.Trim();
                cmd.Parameters.Add("@PartName", SqlDbType.VarChar).Value = txtpartname.Text.Trim();
                cmd.Parameters.Add("@PartNo", SqlDbType.VarChar).Value = txtpartno.Text.Trim();
                cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();
                // IMAGE SAVE
                if (FileMCImage.HasFile)
                {
                    string Filenamenew = FileMCImage.FileName;
                    string codenew = Guid.NewGuid().ToString();

                    string folderPath = Server.MapPath("~/Content/MyProducts/");

                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileName = codenew + "_" + Filenamenew;
                    string fullPath = Path.Combine(folderPath, fileName);

                    FileMCImage.SaveAs(fullPath);

                    cmd.Parameters.AddWithValue("@ImagenamePath",
                        "~/MyProducts/" + fileName);
                }
                else
                {
                    DataTable dtImage = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter("SELECT ImagenamePath FROM tbl_ProdcutMaster WHERE ID=@Id", con);
                    da.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(string.IsNullOrWhiteSpace(hdnVal.Value) ? "0" : hdnVal.Value));
                    da.Fill(dtImage);

                    if (dtImage.Rows.Count > 0)
                    {
                        cmd.Parameters.AddWithValue("@ImagenamePath", dtImage.Rows[0]["ImagenamePath"]);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@ImagenamePath", DBNull.Value);
                    }
                }

                if (btnsave.Text == "Update")
                {
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = Convert.ToInt32(hdnVal.Value);
                    cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateProduct";
                }
                else
                {
                    cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertProduct";
                }
                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();

                if (btnsave.Text == "Update")
                {
                    Session["message"] = "Product updated successfully.";
                }
                else
                {
                    Session["message"] = "Product created successfully.";
                }
                Session["icon"] = "success";
                Session["time"] = "2000";
                Session["url"] = "/Admin/ProductList.aspx";
                Response.Redirect("/Alerts.aspx");

            }
        }
        catch (Exception)
        {
            throw;
        }     
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductsMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "ProductListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtproductcode.Text = dt.Rows[0]["Productcode"].ToString();
            txtproductname.Text = dt.Rows[0]["Productname"].ToString();
            txtThickness.Text = dt.Rows[0]["Thickness"].ToString();
            ddlSize.SelectedValue = dt.Rows[0]["Size"].ToString();
            txtpartname.Text = dt.Rows[0]["PartName"].ToString();
            txtpartno.Text = dt.Rows[0]["PartNo"].ToString();
           
            btnsave.Text = "Update";
        }
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetProductnameList(string prefixText, int count)
    {
        return AutoFillGetProductnameList(prefixText);
    }

    public static List<string> AutoFillGetProductnameList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                Productname
            FROM tbl_ProdcutMaster
            WHERE Productname LIKE '%'+ @Search + '%'
            AND isdeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["Productname"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }
}
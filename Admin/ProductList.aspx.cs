using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI.WebControls;

public partial class ProductList : System.Web.UI.Page
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

                FillGrid();
            }
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        Response.Redirect("ProductMaster.aspx");
    }

    protected void btnrefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect("ProductList.aspx");
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void GVDetails_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RowEdit")
        {
            Response.Redirect("ProductMaster.aspx?Id=" + objcls.encrypt(e.CommandArgument.ToString()) + "");
        }
        if (e.CommandName == "RowDelete")
        {
            SqlCommand Cmd = new SqlCommand("SP_ProductsMaster", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@SP_Action", "Deleteproduct");
            Cmd.Parameters.AddWithValue("@Id", e.CommandArgument.ToString());
            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Product deleted successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/ProductList.aspx";
            Response.Redirect("/Alerts.aspx");
        }
    }

    protected void GVDetails_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }

    protected void txtproductname_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetCompanyList(string prefixText, int count)
    {
        return AutoFillCompanyName(prefixText);
    }

    public static List<string> AutoFillCompanyName(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
            Productname
            FROM tbl_prodcutmaster
            WHERE Productname LIKE '%'+ @Search + '%'
            AND IsDeleted = 0", con))
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

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductsMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "ProductList");
        cmd.SelectCommand.Parameters.AddWithValue("Productname", txtproductname.Text);
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.Fill(dt);
        GVDetails.DataSource = dt;
        GVDetails.DataBind();
    }

    [System.Web.Services.WebMethod]
    public static string UpdateUserSetting(int id, bool val)
    {
        string query = "UPDATE tbl_ProdcutMaster SET IsActive=@val WHERE ID=@id";

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@val", val);
                cmd.Parameters.AddWithValue("@id", id);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        return "Success";
    }
}
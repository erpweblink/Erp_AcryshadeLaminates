using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_TransporterList : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'TransporterList.aspx'";
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
        Response.Redirect("TransporterMaster.aspx");
    }

    protected void txttransportrename_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void btnrefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect("TransporterList.aspx");
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void GVDetails_RowDataBound(object sender, GridViewRowEventArgs e)
    {
         
    }

    protected void GVDetails_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //FillGrid();

        int id = Convert.ToInt32(e.CommandArgument.ToString());
        if (e.CommandName == "RowEdit")
        {
            Response.Redirect("TransporterMaster.aspx?Id=" + objcls.encrypt(e.CommandArgument.ToString()) + "");
        }
        if (e.CommandName == "RowDelete")
        {
            SqlCommand Cmd = new SqlCommand("Sp_TransporterMaster", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@SP_Action", "DeleteTransporter");
            Cmd.Parameters.AddWithValue("@Id", id);
            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Transporter deleted successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/TransporterList.aspx";
            Response.Redirect("/Alerts.aspx");
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("Sp_TransporterMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "TransporterList");
        cmd.SelectCommand.Parameters.AddWithValue("@transporter_name", txttransportrename.Text);
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.Fill(dt);
        GVDetails.DataSource = dt;
        GVDetails.DataBind();
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
                transporter_name
            FROM Transportermaster
            WHERE transporter_name LIKE '%'+ @Search + '%'
            AND IsDeleted = 0", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["transporter_name"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }

}
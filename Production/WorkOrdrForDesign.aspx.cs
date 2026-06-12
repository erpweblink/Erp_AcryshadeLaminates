using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI.WebControls;

public partial class WorkOrdrForDesign : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'WorkOrdrForDesign.aspx'";
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

    protected void Gvdetails_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Approved")
        {
            SqlCommand Cmd = new SqlCommand("SP_WorkOrderMaster", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@SP_Action", "approveworkorder");
            Cmd.Parameters.AddWithValue("@Id", e.CommandArgument.ToString());
            Cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Work order approved successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Production/WorkOrdrForDesign.aspx";
            Response.Redirect("/Alerts.aspx");
        }
        if (e.CommandName == "DisApproved")
        {
            SqlCommand Cmd = new SqlCommand("SP_WorkOrderMaster", con);
            Cmd.CommandType = CommandType.StoredProcedure;
            Cmd.Parameters.AddWithValue("@SP_Action", "DisApprove");
            Cmd.Parameters.AddWithValue("@Id", e.CommandArgument.ToString());
            Cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
            con.Open();
            Cmd.ExecuteNonQuery();
            con.Close();

            Session["message"] = "Work order disapproved successfully.";
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Production/WorkOrdrForDesign.aspx";
            Response.Redirect("/Alerts.aspx");
        }
        if (e.CommandName == "RowPO")
        {
            string ID = e.CommandArgument.ToString();
            string fileName = Path.GetFileName(e.CommandArgument.ToString());
            Response.Redirect("~/Content/WOAttachedFiles/" + fileName);
        }
    }

    protected void Gvdetails_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int headerId = Convert.ToInt32(Gvdetails.DataKeys[e.Row.RowIndex].Value);

            GridView gvCompany = e.Row.FindControl("GVCompany") as GridView;

            SqlCommand cmd = new SqlCommand(@"SELECT Id, HeaderID, ProductId, ProductName,
                      PartNo, Description,Size, Unit, Qty, SqFeet, UploadedImage FROM tbl_WorkOrderDetails
                    WHERE HeaderID = @HeaderID", con);

            cmd.Parameters.AddWithValue("@HeaderID", headerId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCompany.DataSource = dt;
            gvCompany.DataBind();
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_WorkOrderMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "WoHdrList");
        cmd.SelectCommand.Parameters.AddWithValue("@Dealer", txtcompanyname.Text);
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        Gvdetails.DataSource = dt;
        Gvdetails.DataBind();
    }

    protected void btnrefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect("WorkOrderList.aspx");
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
                Dealer
            FROM tbl_WorkOrderHdr
            WHERE Dealer LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["Dealer"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }


    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void txtcompanyname_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

}
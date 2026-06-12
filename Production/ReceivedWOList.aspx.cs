using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class ReceivedWOList : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'ReceivedWOList.aspx'";
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

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductionsPlanning", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "ProductionSchedular");
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ViewWorkOrder")
        {
            BindPopupGrid(e.CommandArgument.ToString());
            ToolkitScriptManager.RegisterStartupScript(this, this.GetType(),
            "Popup",
            "var myModal = new bootstrap.Modal(document.getElementById('detailsModal')); myModal.show();",
            true);
        }
    }

    protected void GVCompany_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes["data-id"] =
                DataBinder.Eval(e.Row.DataItem, "ID").ToString();

            e.Row.CssClass += " drag-row";
        }
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    public class RankModel
    {
        public int id { get; set; }
        public int rank { get; set; }
    }

    // ===================== WEB METHOD =====================
    [WebMethod]
    public static void UpdateRank(List<RankModel> list)
    {
        string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
        using (SqlConnection con = new SqlConnection(conStr))
        {
            con.Open();
            foreach (var item in list)
            {
                SqlCommand cmd = new SqlCommand(@"
                UPDATE tbl_WorkOrderHdr
                SET RankNo = @Rank
                WHERE ID = @ID", con);

                cmd.Parameters.AddWithValue("@Rank", item.rank);
                cmd.Parameters.AddWithValue("@ID", item.id);
                cmd.ExecuteNonQuery();
            }
        }
    }

    protected void btnReloadGrid_Click(object sender, EventArgs e)
    {
        FillGrid(); 
    }

    private void BindPopupGrid(string headerId)
    {

        SqlCommand cmd = new SqlCommand(@"
        SELECT Id, HeaderID, ProductId, ProductName, PartNo, Description,
               Size, Unit, Qty
                
        FROM tbl_WorkOrderDetails
        WHERE HeaderID = @HeaderID", con);

        cmd.Parameters.AddWithValue("@HeaderID", headerId);

        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        da.Fill(dt);

        GvPopup.DataSource = dt;
        GvPopup.DataBind();
    }
}



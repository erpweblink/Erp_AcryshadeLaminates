using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class Delivery : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'Delivery.aspx'";
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
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "GetDeliveryList");
        cmd.SelectCommand.Parameters.AddWithValue("@ProductName", txtcompanyname.Text);
        cmd.SelectCommand.Parameters.AddWithValue("@ShowRecords", ddlPageSize.SelectedValue);
        cmd.SelectCommand.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
    }

    protected void GVCompany_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RowPO")
        {
            string ID = e.CommandArgument.ToString();
            string fileName = Path.GetFileName(e.CommandArgument.ToString());
            Response.Redirect("~/Content/WOAttachedFiles/" + fileName);
        }
        if (e.CommandName == "UpdateStatus")
        {
            string[] args = e.CommandArgument.ToString().Split(',');

            int id = Convert.ToInt32(args[0]);
            bool isProductionCompleted = Convert.ToBoolean(args[1]);
            bool isDispatched = Convert.ToBoolean(args[2]);

            if (isDispatched)
            {
                hfOrderId.Value = id.ToString();

                ScriptManager.RegisterStartupScript(
                    this,
                    GetType(),
                    "showModal",
                    "$('#deliveryModal').modal('show');",
                    true);

                return;
            }
            else
            {
                SqlCommand Cmd = new SqlCommand("SP_ProductionsPlanning", con);
                Cmd.CommandType = CommandType.StoredProcedure;
                Cmd.Parameters.AddWithValue("@SP_Action", "IsDipatchedStatus");
                Cmd.Parameters.AddWithValue("@Id", args[0]);
                Cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
                con.Open();
                Cmd.ExecuteNonQuery();
                con.Close();

                int PalcOrderId = 0;
                string getStage2 = @"SELECT ISNULL(PlaceOrderID,0) as PlaceOrder FROM tbl_WorkOrderHDR
                           WHERE ID = @WoId ";

                using (SqlCommand cmd = new SqlCommand(getStage2, con))
                {
                    cmd.Parameters.AddWithValue("@WoId", args[0]);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            PalcOrderId = Convert.ToInt32(dr["PlaceOrder"]);
                        }
                    }
                }
                if (PalcOrderId != 0)
                {
                    string querys = @"
                                UPDATE tbl_DealersOrderHDR
                                SET DispatchedStatus = @DispatchedStatus
                                WHERE ID = @Id";

                    using (SqlCommand cmds = new SqlCommand(querys, con))
                    {
                        cmds.Parameters.AddWithValue("@DispatchedStatus", "Order Dispatched");
                        cmds.Parameters.AddWithValue("@Id", PalcOrderId);

                        cmds.ExecuteNonQuery();
                    }
                }


                Session["message"] = "Work Order Dispatched successfully.";
                Session["icon"] = "success";
                Session["time"] = "2000";
                Session["url"] = "/Production/Delivery.aspx";
                Response.Redirect("/Alerts.aspx");
            }            
        }
    }

    protected void btnrefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect("Delivery.aspx");
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

    protected void txtCustomerName_TextChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void GVCompany_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int headerId = Convert.ToInt32(GVCompany.DataKeys[e.Row.RowIndex].Value);

            GridView gvDetails = e.Row.FindControl("gvDetails") as GridView;

            SqlCommand cmd = new SqlCommand(@"SELECT Id, HeaderID, ProductId, ProductName,
                      PartNo, Description,Size, Unit, Qty, SqFeet, UploadedImage FROM tbl_WorkOrderDetails
                    WHERE HeaderID = @HeaderID", con);

            cmd.Parameters.AddWithValue("@HeaderID", headerId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvDetails.DataSource = dt;
            gvDetails.DataBind();
        }
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        FillGrid();
    }

    protected void btnConfirmDelivery_Click(object sender, EventArgs e)
    {
       
        string id = hfOrderId.Value.ToString();

        string remark = txtRemark.Text.Trim();

        string fileName = "";

        if (fuLRCopy.HasFile)
        {
            string Filenamenew = fuLRCopy.FileName;
            string codenew = Guid.NewGuid().ToString();

            string folderPath = Server.MapPath("~/Content/LR_Attached/");

            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            fileName = codenew + "_" + Filenamenew;
            string fullPath = Path.Combine(folderPath, fileName);

            fuLRCopy.SaveAs(fullPath);
        }

        SqlCommand Cmd = new SqlCommand("SP_ProductionsPlanning", con);
        Cmd.CommandType = CommandType.StoredProcedure;
        Cmd.Parameters.AddWithValue("@SP_Action", "IsCompletedStatus");
        Cmd.Parameters.AddWithValue("@Id", id);
        Cmd.Parameters.AddWithValue("@IsLRAttached", "~/LR_Attached/" + fileName);
        Cmd.Parameters.AddWithValue("@MachineID", HttpContext.Current.Session["ID"].ToString());
        Cmd.Parameters.AddWithValue("@Remark", remark);
        Cmd.Parameters.Add("@Result", SqlDbType.Int).Direction = ParameterDirection.Output;
        con.Open();
        Cmd.ExecuteNonQuery();
        con.Close();

        ScriptManager.RegisterStartupScript(
            this,
            GetType(),
            "hideModal",
            "$('#deliveryModal').modal('hide');",
            true);
    }

}



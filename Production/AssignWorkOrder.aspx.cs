using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class AssignWorkOrder : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);

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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'AssignWorkOrder.aspx'";
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
                LoadStageCapacity();
                FillGrid();
            }
        }
    }

    private void LoadStageCapacity()
    {
        using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", "GetCapacity");
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvStageCapacity.DataSource = dt;
            gvStageCapacity.DataBind();
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_ProductionsPlanning", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "ScheduledWorkOrder");
        cmd.Fill(dt);
        GVCompany.DataSource = dt;
        GVCompany.DataBind();
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

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        Save_Data("Multiple");
    }

    protected void btnSend_Click(object sender, EventArgs e)
    {
        Save_Data("Single");
    }

    protected void Save_Data(string Frombtn)
    {
        string MachineID = "";
        foreach (GridViewRow g1 in gvStageCapacity.Rows)
        {
            CheckBox chkSelect = g1.FindControl("chkMachine") as CheckBox;
            if (chkSelect.Checked)
            {
                Label MachineId = (Label)g1.FindControl("lblMachineID");
                MachineID = MachineId.Text;
                break;
            }
        }

        if (Frombtn == "Multiple")
        {
            if (!string.IsNullOrWhiteSpace(MachineID))
            {
                foreach (GridViewRow g2 in GVCompany.Rows)
                {
                    CheckBox chkSelect = g2.FindControl("chkSend") as CheckBox;
                    if (chkSelect.Checked)
                    {
                        Label lblWoID = (Label)g2.FindControl("lblWoID");

                        DataTable Dt = new DataTable();
                        SqlDataAdapter da = new SqlDataAdapter("SELECT ProductName,PartNo,Size,Qty FROM tbl_WorkOrderdetails WHERE HeaderID='" + lblWoID.Text + "'", con);
                        da.Fill(Dt);
                        foreach (DataRow dr in Dt.Rows)
                        {
                            using (SqlCommand cmd = new SqlCommand("SP_ProductionsPlanning", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;

                                cmd.Parameters.AddWithValue("@MachineId", MachineID);
                                cmd.Parameters.AddWithValue("@WOHeaderId", lblWoID.Text);
                                cmd.Parameters.AddWithValue("@ProductName", dr["ProductName"].ToString());
                                cmd.Parameters.AddWithValue("@PartNo", dr["PartNo"].ToString());
                                cmd.Parameters.AddWithValue("@Size", dr["Size"].ToString());
                                cmd.Parameters.AddWithValue("@ReceivedQty", dr["Qty"].ToString());
                                cmd.Parameters.AddWithValue("@SP_Action", "InsertWOToProd");

                                con.Open();
                                cmd.ExecuteNonQuery();
                                con.Close();
                            }
                        }
                    }
                }

                Session["message"] = "Work Order Sent To Production.";
                Session["icon"] = "success";
                Session["time"] = "2000";
                Session["url"] = "/Production/AssignWorkOrder.aspx";
                Response.Redirect("/Alerts.aspx");
            }
            else
            {
                Session["message"] = "Please select atleast one work order and available machine.";
                Session["icon"] = "warning";
                Session["time"] = "2000";
                Session["url"] = "/Production/AssignWorkOrder.aspx";
                Response.Redirect("/Alerts.aspx");
            }
        }
        else
        {
            if (!string.IsNullOrWhiteSpace(MachineID))
            {

            }

        }
    }

    [System.Web.Services.WebMethod]
    public static string UpdatePriority(int id, string priority)
    {
        using (SqlConnection con = new SqlConnection(
            ConfigurationManager.ConnectionStrings["con"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE tbl_WorkOrderHdr SET SetPriority=@Priority WHERE ID=@ID", con);

            cmd.Parameters.AddWithValue("@Priority", priority);
            cmd.Parameters.AddWithValue("@ID", id);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        return "Success";
    }
}


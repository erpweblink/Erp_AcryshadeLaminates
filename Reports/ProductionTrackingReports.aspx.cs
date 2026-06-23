using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ProductionTrackingReports : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            FillGrid();
        }
    }

    private void FillGrid()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_Reports", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "productionsreports");
        cmd.Fill(dt);
        GVdetails.DataSource = dt;
        GVdetails.DataBind();
    }


    protected void GVdetails_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }

    protected void GVdetails_RowCommand(object sender, GridViewCommandEventArgs e)
    {

    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        GVdetails.AllowPaging = false;

        FillGrid(); // rebind data

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition",
            "attachment;filename=ProductionTrackingReport.xls");
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";

        using (StringWriter sw = new StringWriter())
        {
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            if (GVdetails.HeaderRow != null)
            {
                GVdetails.HeaderRow.BackColor = System.Drawing.Color.White;

                foreach (TableCell cell in GVdetails.HeaderRow.Cells)
                {
                    cell.BackColor = GVdetails.HeaderStyle.BackColor;
                }
            }

            foreach (GridViewRow row in GVdetails.Rows)
            {
                row.BackColor = System.Drawing.Color.White;
            }

            GVdetails.RenderControl(hw);

            Response.Write(sw.ToString());
            Response.Flush();
            Response.End();
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }
}
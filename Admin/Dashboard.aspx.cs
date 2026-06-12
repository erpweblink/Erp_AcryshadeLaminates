using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;


public partial class Dashboard : System.Web.UI.Page
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
                if (Session["Role"].ToString() != "Admin")
                {
                    divAdmin.Visible = false;
                }
                GetDashboard();
            }
        }

    }

    protected void GetDashboard()
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("SP_DashboardDetails", con);
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "CardsDetails");
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            lbldealerCount.InnerText = dt.Rows[0]["DealersCount"].ToString();
            lblStages.InnerText = dt.Rows[0]["StageCount"].ToString();
            lblMachines.InnerText = dt.Rows[0]["MachineCount"].ToString();
            lblCapacity.InnerText = dt.Rows[0]["UnitCapacity"].ToString();
        }
        else
        {
            lbldealerCount.InnerText = "0";
            lblStages.InnerText = "0";
            lblMachines.InnerText = "0";
            lblCapacity.InnerText = "0";
        }
    }

    [WebMethod]
    public static object GetCardDetails(string cardName)
    {
        List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(cs))
        {
            SqlCommand cmd = new SqlCommand("SP_DashboardDetails", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SP_Action", cardName);

            con.Open();

            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    Dictionary<string, object> row = new Dictionary<string, object>();

                    for (int i = 0; i < dr.FieldCount; i++)
                    {
                        row.Add(dr.GetName(i), dr[i]);
                    }

                    rows.Add(row);
                }
            }
        }

        return rows;
    }
}



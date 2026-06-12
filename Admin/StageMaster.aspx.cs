using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.EnterpriseServices;
using System.Web.Script.Services;
using System.Web.Services;


public partial class StageMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'StageList.aspx'";
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
        SqlDataAdapter cmd = new SqlDataAdapter("SP_StageMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "StageListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtStageName.Text = dt.Rows[0]["SatgeName"].ToString();
            txtStageDesc.Text = dt.Rows[0]["SatgeDescription"].ToString();
            txtStageCapi.Text = dt.Rows[0]["SatgeCapacity"].ToString();
            txtCapiUnit.Text = dt.Rows[0]["CapacityUnit"].ToString();
            btnsave.Text = "Update";
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_StageMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@SatgeName", SqlDbType.VarChar).Value = txtStageName.Text;
            cmd.Parameters.Add("@SatgeDescription", SqlDbType.VarChar).Value = txtStageDesc.Text;
            cmd.Parameters.Add("@SatgeCapacity", SqlDbType.VarChar).Value = txtStageCapi.Text;
            cmd.Parameters.Add("@CapacityUnit", SqlDbType.VarChar).Value = txtCapiUnit.Text;
            cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();

            if (btnsave.Text == "Update")
            {
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(hdnVal.Value);
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateStage";
            }
            else
            {
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertStage";
            }
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            if (btnsave.Text == "Update")
            {
                Session["message"] = "Stage updated successfully.";
            }
            else
            {
                Session["message"] = "Stage created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/StageList.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void btn_DeList_click(object sender, EventArgs e)
    {
        Response.Redirect("StageList.aspx");
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetStageList(string prefixText, int count)
    {
        return AutoFillGetStageList(prefixText);
    }

    public static List<string> AutoFillGetStageList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                SatgeName
            FROM tbl_StageMaster
            WHERE SatgeName LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["SatgeName"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetUnitList(string prefixText, int count)
    {
        return AutoFillGetUnitList(prefixText);
    }

    public static List<string> AutoFillGetUnitList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                CapacityUnit
            FROM tbl_StageMaster
            WHERE CapacityUnit LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["CapacityUnit"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }
}



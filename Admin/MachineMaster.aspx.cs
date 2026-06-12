using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI.WebControls;


public partial class MachineMaster : System.Web.UI.Page
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
                        string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'MachineList.aspx'";
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


                DataTable dt = new DataTable();
                SqlDataAdapter cmd = new SqlDataAdapter("SP_MachineMaster", con);
                cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
                cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "StageList");
                cmd.Fill(dt);
                if (dt.Rows.Count > 0)
                {
                    ddlStage.DataSource = dt;
                    ddlStage.DataTextField = "SatgeName";
                    ddlStage.DataValueField = "SatgeName";
                    ddlStage.DataBind();

                    ddlStage.Items.Insert(0, new ListItem("--Select Stage--", ""));
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
        SqlDataAdapter cmd = new SqlDataAdapter("SP_MachineMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "MachineListById");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtMachineName.Text = dt.Rows[0]["MachineName"].ToString();
            txtMCDesc.Text = dt.Rows[0]["MachineDescription"].ToString();
            txtMCPerHrQty.Text = dt.Rows[0]["MachinePerHRQty"].ToString();
            txtRunHr.Text = dt.Rows[0]["MachineRunningHR"].ToString();

            if (dt.Rows[0]["MachineImage"] != DBNull.Value)
            {
                lblUploadedName.Text = dt.Rows[0]["MachineImageName"].ToString();

                byte[] bytes = (byte[])dt.Rows[0]["MachineImage"];

                string base64String = Convert.ToBase64String(bytes);

                imgPreview.ImageUrl = "data:image/png;base64," + base64String;

                imgPreview.Visible = true;
                lblUploadedName.Visible = true;
            }

            ddlStage.SelectedValue = dt.Rows[0]["AllocatedStage"].ToString();
            btnsave.Text = "Update";
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("SP_MachineMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@MachineName", SqlDbType.VarChar).Value = txtMachineName.Text.Trim();
            cmd.Parameters.Add("@MachineDescription", SqlDbType.VarChar).Value = txtMCDesc.Text.Trim();
            cmd.Parameters.Add("@MachinePerHRQty", SqlDbType.VarChar).Value = txtMCPerHrQty.Text.Trim();
            cmd.Parameters.Add("@MachineRunningHR", SqlDbType.VarChar).Value = txtRunHr.Text.Trim();
            cmd.Parameters.Add("@AllocatedStage", SqlDbType.VarChar).Value = ddlStage.SelectedValue;
            cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();

            // IMAGE SAVE
            if (FileMCImage.HasFile)
            {
                byte[] imageBytes = FileMCImage.FileBytes;
                string fileName = Path.GetFileName(FileMCImage.FileName);

                cmd.Parameters.Add("@MachineImage", SqlDbType.VarBinary).Value = imageBytes;
                cmd.Parameters.Add("@MachineImageName", SqlDbType.VarChar).Value = fileName;
            }
            else
            {
                DataTable dtImage = new DataTable();

                SqlDataAdapter da = new SqlDataAdapter(
                    "SELECT MachineImage, MachineImageName FROM tbl_MachineMaster WHERE Id=@Id",
                    con);

                da.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(String.IsNullOrWhiteSpace(hdnVal.Value)?"0": hdnVal.Value));

                da.Fill(dtImage);

                if (dtImage.Rows.Count > 0)
                {
                    cmd.Parameters.Add("@MachineImage", SqlDbType.VarBinary)
                        .Value = dtImage.Rows[0]["MachineImage"];

                    cmd.Parameters.Add("@MachineImageName", SqlDbType.VarChar)
                        .Value = dtImage.Rows[0]["MachineImageName"].ToString();
                }
                else
                {
                    cmd.Parameters.Add("@MachineImage", SqlDbType.VarBinary).Value = DBNull.Value;
                    cmd.Parameters.Add("@MachineImageName", SqlDbType.VarChar).Value = DBNull.Value;
                }
            }

            if (btnsave.Text == "Update")
            {
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(hdnVal.Value);
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateMachine";
            }
            else
            {
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertMachine";
            }
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            if (btnsave.Text == "Update")
            {
                Session["message"] = "Machine updated successfully.";
            }
            else
            {
                Session["message"] = "Machine created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/MachineList.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void btn_DeList_click(object sender, EventArgs e)
    {
        Response.Redirect("MachineList.aspx");
    }

    [ScriptMethod()]
    [WebMethod]
    public static List<string> GetMachineList(string prefixText, int count)
    {
        return AutoFillGetMachineList(prefixText);
    }

    public static List<string> AutoFillGetMachineList(string prefixText)
    {
        using (SqlConnection con = new SqlConnection())
        {
            con.ConnectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlCommand cmd = new SqlCommand(@"
            SELECT DISTINCT 
                MachineName
            FROM tbl_MachineMaster
            WHERE MachineName LIKE '%'+ @Search + '%'
            AND IsDeleted = 0 ", con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);

                con.Open();
                List<string> countryNames = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        countryNames.Add(sdr["MachineName"].ToString());
                    }
                }
                con.Close();
                return countryNames;
            }
        }
    }

}



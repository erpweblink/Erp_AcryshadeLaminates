using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class Admin_TransporterMaster : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
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


            string encryptedId = Request.QueryString["Id"];

            if (!string.IsNullOrEmpty(encryptedId))
            {
                string ID = objcls.Decrypt(encryptedId);

                hdnVall.Value = ID;

                LoadData(ID);
            }
        }
    }

    protected void ddlUserType_TextChanged(object sender, EventArgs e)
    {
        Response.Redirect("TransporterList.aspx");
    }

    protected void btnsave_Click(object sender, EventArgs e)
    {
        using (SqlCommand cmd = new SqlCommand("Sp_TransporterMaster", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@transporter_name", SqlDbType.VarChar).Value = txtTransporeteFName.Text;
            cmd.Parameters.Add("@transporter_code", SqlDbType.VarChar).Value = txtTransportercode.Text;
            cmd.Parameters.Add("@gst_no", SqlDbType.VarChar).Value = txtGstNo.Text;
            cmd.Parameters.Add("@contact_person", SqlDbType.VarChar).Value = txtcontactperson.Text;
            cmd.Parameters.Add("@pan_no", SqlDbType.VarChar).Value = txtPanCard.Text;
            cmd.Parameters.Add("@email", SqlDbType.VarChar).Value = txtEmailID.Text;
            cmd.Parameters.Add("@mobile", SqlDbType.VarChar).Value = txtMobileNo.Text;
            cmd.Parameters.Add("@address", SqlDbType.VarChar).Value = txtaddress.Text;
            cmd.Parameters.Add("@city", SqlDbType.VarChar).Value = Txtcity.Text;
            cmd.Parameters.Add("@state", SqlDbType.VarChar).Value = txtstate.Text;
            cmd.Parameters.Add("@pincode", SqlDbType.VarChar).Value = txtpincode.Text;
            cmd.Parameters.Add("@vehicle_type", SqlDbType.VarChar).Value = txtvehical.Text;
            cmd.Parameters.Add("@rate_per_km", SqlDbType.VarChar).Value = txtratekm.Text;
            cmd.Parameters.Add("@service_route", SqlDbType.VarChar).Value = txtServiceRoute.Text;
            cmd.Parameters.Add("@bank_name", SqlDbType.VarChar).Value = txtbankname.Text;
            cmd.Parameters.Add("@ifsc_code", SqlDbType.VarChar).Value = txtifsc.Text;
            cmd.Parameters.Add("@account_no", SqlDbType.VarChar).Value = txtaccountno.Text;
            cmd.Parameters.Add("@ActionBy", SqlDbType.VarChar).Value = Session["ID"].ToString();
            if (btnsave.Text == "Update")
            {
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(hdnVall.Value);
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "UpdateTransporter";
            }
            else
            {
                cmd.Parameters.Add("@SP_Action", SqlDbType.VarChar).Value = "InsertDealer";
            }
            con.Open();
            cmd.ExecuteNonQuery();
            con.Close();

            if (btnsave.Text == "Update")
            {
                Session["message"] = "Transporter updated successfully.";
            }
            else
            {
                Session["message"] = "Transporter created successfully.";
            }
            Session["icon"] = "success";
            Session["time"] = "2000";
            Session["url"] = "/Admin/TransporterList.aspx";
            Response.Redirect("/Alerts.aspx");

        }
    }

    protected void btnDeList_Click(object sender, EventArgs e)
    {
        Response.Redirect("TransporterList.aspx");
    }

    protected void LoadData(string ID)
    {
        DataTable dt = new DataTable();
        SqlDataAdapter cmd = new SqlDataAdapter("Sp_TransporterMaster", con);
        cmd.SelectCommand.CommandType = CommandType.StoredProcedure;
        cmd.SelectCommand.Parameters.AddWithValue("@SP_Action", "GetByTransporterbyId");
        cmd.SelectCommand.Parameters.AddWithValue("@Id", Convert.ToInt32(ID));
        cmd.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            txtTransportercode.Text = dt.Rows[0]["transporter_code"].ToString();
            txtTransporeteFName.Text = dt.Rows[0]["transporter_name"].ToString();
            txtGstNo.Text = dt.Rows[0]["gst_no"].ToString();
            txtPanCard.Text = dt.Rows[0]["pan_no"].ToString();
            txtcontactperson.Text = dt.Rows[0]["contact_person"].ToString();
            txtMobileNo.Text = dt.Rows[0]["mobile"].ToString();
            txtEmailID.Text = dt.Rows[0]["email"].ToString();
            txtaddress.Text = dt.Rows[0]["address"].ToString();
            Txtcity.Text = dt.Rows[0]["city"].ToString();
            txtstate.Text = dt.Rows[0]["state"].ToString();
            txtpincode.Text = dt.Rows[0]["pincode"].ToString();
            txtvehical.Text = dt.Rows[0]["vehicle_type"].ToString();
            txtratekm.Text = dt.Rows[0]["rate_per_km"].ToString();
            txtbankname.Text = dt.Rows[0]["bank_name"].ToString();
            txtServiceRoute.Text = dt.Rows[0]["serviceRoute"].ToString();
            txtifsc.Text = dt.Rows[0]["ifsc_code"].ToString();
            txtaccountno.Text = dt.Rows[0]["account_no"].ToString();
            btnsave.Text = "Update";
        }
    }
}
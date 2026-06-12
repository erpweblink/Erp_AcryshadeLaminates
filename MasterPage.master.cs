using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class MasterPage : System.Web.UI.MasterPage
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            UserNameShow();
            PageAuthorization();
        }
    }

    protected void UserNameShow()
    {
        if (Session["UserCode"] != null)
        {
            string email = Session["EmailID"].ToString();

            spnUserName.InnerText = email;

            string[] colors =
            {
                "#4285F4", "#EA4335", "#FBBC05", "#34A853",
                "#9C27B0", "#FF5722", "#009688"
            };

            string firstLetter = email.Substring(0, 1).ToUpper();
            int index = firstLetter[0] % colors.Length;

            divAvatar.InnerText = firstLetter;

            // Dynamic styles
            divAvatar.Style["width"] = "29px";
            divAvatar.Style["height"] = "27px";
            divAvatar.Style["border-radius"] = "17%";
            divAvatar.Style["background-color"] = colors[index];
            divAvatar.Style["color"] = "white";
            divAvatar.Style["display"] = "flex";
            divAvatar.Style["align-items"] = "center";
            divAvatar.Style["justify-content"] = "center";
            divAvatar.Style["font-size"] = "18px";
            divAvatar.Style["font-weight"] = "bold";
            divAvatar.Style["text-transform"] = "uppercase";
        }
    }

    protected void PageAuthorization()
    {
        string username = Session["ID"].ToString();
        DataTable dt = new DataTable();
        SqlCommand cmd1 = new SqlCommand("SELECT * FROM tbl_UserRoleAuthorization WHERE UserID='" + username + "'", con);
        SqlDataAdapter sad = new SqlDataAdapter(cmd1);
        sad.Fill(dt);
        if (dt.Rows.Count > 0)
        {
            foreach (DataRow row in dt.Rows)
            {
                string MenuName = row["PageName"].ToString();

                /*Dashboard*/
                {
                    if (MenuName == "Dashboard.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        DashboardTab.Visible = PageAccess == "True" ? true : false;
                    }
                }
                /*End*/

                /* Master Tab */
                {
                    if (MenuName == "RoleMaster.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        RolesTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "UserList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        UsersTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "DealerList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        DealersTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "CompanyList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        CompaniesTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "StageList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        StagesTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "MachineList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        MachineTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "RawMaterialList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        RawMatTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "ProductList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        ProductTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "TransporterList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        TransTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (RolesTab.Visible == false && UsersTab.Visible == false && DealersTab.Visible == false &&
                       CompaniesTab.Visible == false && StagesTab.Visible == false && MachineTab.Visible == false &&
                       RawMatTab.Visible == false && ProductTab.Visible == false && TransTab.Visible == false)
                    {
                        MasterTab.Visible = false;
                    }
                }
                /*End*/

                /*WorkOrder*/
                {
                    if (MenuName == "WorkOrderList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        WOrdTab.Visible = PageAccess == "True" ? true : false;
                    }
                }
                /*End*/

                /*Scheduler*/
                {
                    if (MenuName == "ReceivedWOList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        SchedTab.Visible = PageAccess == "True" ? true : false;
                    }
                }
                /*End*/

                /*Production*/
                {

                    if (MenuName == "AssignMachine.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        AssMCTab.Visible = PageAccess == "True" ? true : false;
                    }
                    
                    if (MenuName == "WorkOrdrForDesign.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        DesAppTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "ReceivedWOList.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        RecWOTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (MenuName == "WOProduction.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        WOProdTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if (AssMCTab.Visible == false && DesAppTab.Visible == false && RecWOTab.Visible == false && WOProdTab.Visible == false)
                    {
                        ProductionTab.Visible = false;
                    }
                }
                /*End*/

                /*Reports*/
                {
                    if (MenuName == "ProductionTrackingReports.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        PTRTab.Visible = PageAccess == "True" ? true : false;
                    }

                    if(PTRTab.Visible== false)
                    {
                        DIvRep.Visible = false;
                    }
                }
                /*End*/

                /*UserAuthorization*/
                {
                    if (MenuName == "UserAuthorization.aspx")
                    {
                        string PageAccess = row["PageAccess"].ToString();
                        UserAuthorTab.Visible = PageAccess == "True" ? true : false;
                    }
                }
                /*End*/
            }
        }
        else
        {
            DashboardTab.Visible = false;
            MasterTab.Visible = false;
            RolesTab.Visible = false;
            UsersTab.Visible = false;
            DealersTab.Visible = false;
            CompaniesTab.Visible = false;
            StagesTab.Visible = false;
            MachineTab.Visible = false;
            RawMatTab.Visible = false;
            ProductTab.Visible = false;
            TransTab.Visible = false;
            WOrdTab.Visible = false;
            SchedTab.Visible = false;
            ProductionTab.Visible = false;
            RecWOTab.Visible = false;
            UserAuthorTab.Visible = false;
        }
    }
}

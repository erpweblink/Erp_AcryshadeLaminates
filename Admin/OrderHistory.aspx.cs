using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;


public partial class OrderHistory : System.Web.UI.Page
{
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
                if (!IsPostBack)
                {
                    //Check if you has access to the page of not
                    {
                        string username = Session["ID"].ToString();
                        using (SqlConnection cons = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
                        {
                            string query = @"SELECT PageAccess FROM tbl_UserRoleAuthorization WHERE UserID = @UserID AND PageName = 'PlaceOrder.aspx'";
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
                }
            }
        }
    }


    [WebMethod]
    public static List<Dictionary<string, object>> GetOrders()
    {
        string cs = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        Dictionary<int, Dictionary<string, object>> orders = new Dictionary<int, Dictionary<string, object>>();

        using (SqlConnection con = new SqlConnection(cs))
        {
            con.Open();

            string query = @"
             SELECT 
                h.ID,h.OrderID,WH.TallyRefNo,ISNULL(WH.ID,0) as TallyRefId, h.DealerID, h.CreatedDate, 
                CASE
                    WHEN DispatchedStatus IS NOT NULL AND DispatchedStatus <> '' THEN DispatchedStatus
                    WHEN PackagingStatus IS NOT NULL AND PackagingStatus <> '' THEN PackagingStatus
                    WHEN ProductionStatus IS NOT NULL AND ProductionStatus <> '' THEN ProductionStatus
                    WHEN DesginStatus IS NOT NULL AND DesginStatus <> '' THEN DesginStatus
                    WHEN h.HoldStatus = 1 THEN 'Order Hold'
                    ELSE OrderStatus
                END AS CurrentStatus,
                h.EstimatedDeliveryDate,
                d.ProductID as MainProdId, d.ID as OrderProdID,WD.Id as WOProdID , d.ProductName, d.ProductType, d.Size,
                d.Qty, d.ImagePathName,d.ProductNote,h.InvoicePath as AttachedPath
            FROM tbl_DealersOrderHDR h
            INNER JOIN tbl_DealersOrderDTLs d ON h.ID = d.HeaderID
            LEFT JOIN tbl_WorkOrderHdr WH ON h.ID = WH.PlaceOrderID
            LEFT JOIN tbl_WorkOrderDetails WD
                ON WD.HeaderID = WH.ID
               AND WD.ProductID = d.ProductID
               AND WD.Size = d.Size
            WHERE h.DealerID = @DealerID
            ORDER BY h.ID DESC";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@DealerID", HttpContext.Current.Session["ID"].ToString());
            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                int id = Convert.ToInt32(dr["ID"]);

                // CREATE HEADER OBJECT IF NOT EXISTS
                if (!orders.ContainsKey(id))
                {
                    orders[id] = new Dictionary<string, object>();

                    orders[id]["ID"] = id;
                    orders[id]["WoID"] = dr["TallyRefId"];
                    orders[id]["OrderID"] = dr["OrderID"];
                    orders[id]["TallyRefNo"] = dr["TallyRefNo"];
                    orders[id]["DealerID"] = dr["DealerID"];
                    orders[id]["CreatedDate"] = Convert.ToDateTime(dr["CreatedDate"]).ToString("dd MMM yyyy");
                    orders[id]["OrderStatus"] = dr["CurrentStatus"].ToString();
                    orders[id]["AttachedPath"] = dr["AttachedPath"].ToString();
                    orders[id]["EstimatedDeliveryDate"] =
                        dr["EstimatedDeliveryDate"] == DBNull.Value
                        ? null
                        : Convert.ToDateTime(dr["EstimatedDeliveryDate"]).ToString("dd MMM yyyy");

                    orders[id]["Products"] = new List<Dictionary<string, object>>();
                }

                // ADD PRODUCT
                var product = new Dictionary<string, object>();
                product["ProductID"] = dr["MainProdId"];
                product["OrderProdID"] = dr["OrderProdID"];
                product["WOProdID"] = dr["WOProdID"];
                product["ProductName"] = dr["ProductName"].ToString();
                product["ProductNote"] = dr["ProductNote"].ToString();
                product["ProductType"] = dr["ProductType"].ToString();
                product["Size"] = dr["Size"].ToString();
                product["Qty"] = dr["Qty"];
                product["ImagePathName"] = dr["ImagePathName"].ToString().Replace("~", "");

                ((List<Dictionary<string, object>>)orders[id]["Products"]).Add(product);
            }
        }

        return new List<Dictionary<string, object>>(orders.Values);
    }

    [WebMethod]
    public static string holdOrder(string orderId, string WorkOId)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();
            string updateQuery = @"
                    UPDATE tbl_DealersOrderHDR
                    SET 
                        HoldStatus = CASE 
                                        WHEN ISNULL(HoldStatus, 0) = 1 THEN 0
                                        ELSE 1
                                     END,
                        HoldDate = CASE 
                                        WHEN ISNULL(HoldStatus, 0) = 1 THEN NULL
                                        ELSE GETDATE()
                                   END
                    WHERE ID = @ID";

            using (SqlCommand cmd = new SqlCommand(updateQuery, con))
            {
                cmd.Parameters.AddWithValue("@ID", orderId);

                cmd.ExecuteNonQuery();
            }

            string updatedQuery = @"UPDATE tbl_WorkOrderHdr
                    SET HoldStatus =CASE 
                                        WHEN ISNULL(HoldStatus , 0) = 1 THEN 0
                                        ELSE 1
                                     END,
                        HoldDate = CASE 
                                        WHEN ISNULL(HoldStatus, 0) = 1 THEN NULL
                                        ELSE GETDATE()
                                   END
                    WHERE ID = @ID";

            using (SqlCommand cmd = new SqlCommand(updatedQuery, con))
            {
                cmd.Parameters.AddWithValue("@ID", WorkOId);
                cmd.ExecuteNonQuery();
            }
        }
        return "true";
    }

    [WebMethod]
    public static string CancelOrder(string orderId, string WorkOId)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();
            string updateQuery = @"
                    UPDATE tbl_DealersOrderHDR
                    SET 
                        OrderStatus = 'Order Canceled',
                        Canceldate =  GETDATE()
                    WHERE ID = @ID";

            using (SqlCommand cmd = new SqlCommand(updateQuery, con))
            {
                cmd.Parameters.AddWithValue("@ID", orderId);

                cmd.ExecuteNonQuery();
            }

            string updatedQuery = @"UPDATE tbl_WorkOrderHdr
                    SET CancelStatus = 1,
                        Canceldate = GETDATE()
                    WHERE ID = @ID";

            using (SqlCommand cmd = new SqlCommand(updatedQuery, con))
            {
                cmd.Parameters.AddWithValue("@ID", WorkOId);

                cmd.ExecuteNonQuery();
            }
        }
        return "true";
    }


}



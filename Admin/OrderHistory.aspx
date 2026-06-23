<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="OrderHistory.aspx.cs" Inherits="OrderHistory" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style type="text/css">
        .order-headerss {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap; /* allows responsiveness */
        }

            /* remove default margin issues */
            .order-headerss h2 {
                margin: 0;
                white-space: nowrap;
            }

        /* optional styling for link h2 */
        .product-link a {
            text-decoration: none;
            font-size: 18px;
        }

        /* Mobile responsiveness */
        @media (max-width: 600px) {
            .order-headerss {
                flex-direction: column;
                align-items: flex-start;
            }

                .order-headerss h2 {
                    white-space: normal;
                }
        }

        .order-details {
            display: none;
            margin-top: 10px;
        }

        .order-header {
            cursor: pointer;
        }

            .order-header:hover {
                background: #f8f8f8;
            }

        .order-container {
            width: 95%;
            margin: auto;
            padding: 20px;
        }

        .order-card {
            background: #fff;
            border-radius: 10px;
            margin-bottom: 20px;
            padding: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }

        .order-status {
            padding: 4px 10px;
            border-radius: 17px;
            font-size: 18px;
            color: #fff;
        }

        .status-placed {
            background: #ff9800;
        }

        .status-shipped {
            background: #2196f3;
        }

        .status-delivered {
            background: #4caf50;
        }

        .products-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 10px;
        }


        .product-row {
            display: flex;
            align-items: center;
            border: 1px solid #f1f1f1;
            border-radius: 8px;
            padding: 10px;
            background: #fafafa;
        }

        .product-row {
            transition: all 0.2s ease;
            cursor: pointer;
            border-left: 4px solid transparent;
        }

            .product-row:hover {
                transform: scale(1.02);
                background: #eef6ff;
                box-shadow: 0 4px 12px rgba(0,0,0,0.12);
                border-color: #cfe3ff;
                border-left: 4px solid #2196f3;
            }

                .product-row:hover .product-name {
                    color: #1976d2;
                }

            .product-row img {
                width: 70px;
                height: 70px;
                object-fit: cover;
                border-radius: 6px;
                margin-right: 15px;
                border: 1px solid #ddd;
            }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .product-meta {
            font-size: 13px;
            color: gray;
        }

        .delivery {
            font-size: 13px;
            color: #333;
        }

        .product-note {
            font-size: 12px;
            color: #666;
            margin: 5px 0;
            line-height: 1.4;
            background: #f9f9f9;
            padding: 6px 8px;
            border-radius: 5px;
        }

        .product-note {
            max-height: 60px;
            overflow: hidden;
        }

            .product-note:hover {
                max-height: none;
            }

        #orderList span[id^="icon_"] {
            font-size: 18px;
            font-weight: bold;
            margin-right: 10px;
        }

        @media (max-width: 768px) {

            .order-container {
                width: 100%;
                padding: 10px;
            }

            .order-card {
                padding: 12px;
            }

            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .order-status {
                font-size: 14px;
                padding: 6px 12px;
                border-radius: 15px;
            }

            .products-container {
                grid-template-columns: 1fr;
            }

            .product-row {
                flex-direction: column;
                text-align: center;
            }

                .product-row img {
                    margin-right: 0;
                    margin-bottom: 10px;
                    width: 90px;
                    height: 90px;
                }

            .product-info {
                width: 100%;
            }

            .product-name {
                font-size: 14px;
            }

            .product-meta {
                font-size: 12px;
            }
        }

        /* ===== MODAL ===== */
        .img-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.9);
            justify-content: center;
            align-items: center;
            z-index: 99999;
        }

            .img-modal img {
                max-width: 90%;
                max-height: 90%;
                border-radius: 14px;
                box-shadow: 0 0 40px rgba(0,0,0,0.6);
            }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 768px) {
            .product-container {
                grid-template-columns: repeat(2, 1fr);
            }

            .product-card img {
                height: 150px;
            }
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            loadOrders();
        });

        function toggleOrder(orderId) {
            $("#details_" + orderId).slideToggle();

            let icon = $("#icon_" + orderId);

            if (icon.text() === "▼")
                icon.text("▲");
            else
                icon.text("▼");

        }

        function loadOrders() {
            $.ajax({
                type: "POST",
                url: "OrderHistory.aspx/GetOrders",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    let orders = response.d;
                    renderOrders(orders);
                },
                error: function (err) {
                    console.log(err);
                }
            });
        }

        function renderOrders(orders) {

            let html = "";

            orders.forEach(o => {

                let statusClass = "";

                if (o.OrderStatus === "Order Placed") statusClass = "status-placed";
                else if (o.OrderStatus === "Shipped") statusClass = "status-shipped";
                else if (o.OrderStatus === "Delivered") statusClass = "status-delivered";

                html += `
                    <div class="order-card">

                        <div class="order-header" onclick="toggleOrder('${o.ID}')">
                            <span id="icon_${o.ID}">▼</span>

                            <div>
                                <b>Order ID:</b> ${o.OrderID}<br/>
                                <small>Placed on: ${o.CreatedDate}</small>
                            </div>

                            <div class="order-status ${statusClass}">
                                ${o.OrderStatus}
                            </div>
                        </div>

                        <div id="details_${o.ID}" class="order-details">

                            <div>
                                <b>Estimated Delivery:</b>
                                ${o.EstimatedDeliveryDate ?? 'Not Updated'}
                            </div>

                            <div class="products-container">
                    `;

                o.Products.forEach(p => {
                    var Image = '/Content/' + p.ImagePathName.replace('~/', '');

                    html += `
                        <div class="product-row">
                            <img src="${Image}" onclick="openModal('${Image}')" />

                            <div class="product-info">
                                <div class="product-name">${p.ProductName}</div>
                        `;

                    if (p.ProductNote && p.ProductNote.trim() !== "") {
                        html += `
                            <div class="product-note">
                                ${p.ProductNote}
                            </div>
                        `;
                    }

                    html += `
                            <div class="product-meta">
                                Type: ${p.ProductType} | Size: ${p.Size}
                            </div>

                            <div class="product-meta">
                                Qty: ${p.Qty}
                            </div>
                        </div>
                    </div>
                    `;
                });

                html += `
                        </div>
                    </div>
                    </div>
                    `;
            });

            $("#orderList").html(html);
        }


        function openModal(src) {

            document.getElementById("imgModal")
                .style.display = "flex";

            document.getElementById("modalImg")
                .src = src;
        }

        function closeModal() {

            document.getElementById("imgModal")
                .style.display = "none";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="order-container">
                <div class="order-headerss">
                    <h2 class="fw-bold">My Orders</h2>
                    <h2 class="product-link">
                        <a href="/Admin/PlaceOrder.aspx">Product List</a>
                    </h2>
                </div>
                <div id="orderList"></div>
            </div>

            <div id="imgModal"
                class="img-modal"
                onclick="closeModal()">

                <img id="modalImg">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

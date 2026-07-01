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
            font-size: 16px;
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

        .order-container {
            width: min(1200px,95%);
            margin: auto;
            padding: 20px;
        }

        .order-card {
            background: #fff;
            border-radius: 14px;
            margin-bottom: 20px;
            padding: 18px;
            box-shadow: 0 8px 20px rgba(0,0,0,.08);
            transition: .25s;
        }

            .order-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 15px 35px rgba(0,0,0,.12);
            }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
            cursor: pointer;
        }

            .order-header:hover {
                background: #fafafa;
            }

            .order-header > div:nth-child(2) {
                flex: 1;
            }

        .order-right {
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .order-status {
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            padding: 8px 15px;
            border-radius: 40px;
            white-space: nowrap;
        }

        .status-placed {
            background: #ff9800;
        }

        .status-delivered {
            background: #198754;
        }

        .status-shipped {
            background: #0d6efd;
        }

        .status-rejected {
            background: #dc3545;
        }

        .pdf-link {
            width: 42px;
            height: 42px;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 50%;
            background: #f4f6f9;
            transition: .2s;
            text-decoration: none;
        }

            .pdf-link:hover {
                background: #dbe9ff;
                transform: scale(1.08);
            }

            .pdf-link i {
                font-size: 24px;
            }

        .progress-ring {
            position: relative;
            width: 46px;
            height: 46px;
        }

            .progress-ring svg {
                width: 46px;
                height: 46px;
                transform: rotate(-90deg);
            }

        .progress-bg {
            stroke: #ddd;
            stroke-width: 4;
            fill: none;
        }

        .progress-fill {
            stroke-width: 4;
            fill: none;
            stroke-linecap: round;
        }

        .progress-text {
            position: absolute;
            inset: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 10px;
            font-weight: bold;
        }

        .products-container {
            margin-top: 18px;
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(320px,1fr));
            gap: 18px;
        }

        .product-row {
            display: flex;
            gap: 15px;
            padding: 12px;
            border-radius: 10px;
            border: 1px solid #eee;
            transition: .25s;
            background: #fff;
        }

            .product-row:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 18px rgba(0,0,0,.08);
                border-color: #0d6efd;
            }

            .product-row img {
                width: 80px;
                height: 80px;
                object-fit: cover;
                border-radius: 8px;
                cursor: pointer;
            }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 6px;
        }

        .product-meta {
            color: #666;
            font-size: 13px;
            margin-top: 3px;
        }

        .product-note {
            margin-top: 8px;
            background: #f7f9fc;
            padding: 8px;
            border-radius: 8px;
            font-size: 12px;
        }

        .order-details {
            display: none;
            margin-top: 18px;
        }

        .img-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.85);
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }

            .img-modal img {
                max-width: 90%;
                max-height: 90%;
                border-radius: 12px;
            }

        @media(max-width:768px) {

            .order-container {
                padding: 10px;
            }

            .order-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .order-right {
                width: 100%;
                justify-content: space-between;
            }

            .products-container {
                grid-template-columns: 1fr;
            }

            .product-row {
                align-items: flex-start;
            }

                .product-row img {
                    width: 70px;
                    height: 70px;
                }

            .order-status {
                font-size: 13px;
            }

            .pdf-link {
                width: 38px;
                height: 38px;
            }
        }

        @media(max-width:480px) {

            .order-right {
                flex-wrap: wrap;
                gap: 10px;
            }

            .order-status {
                width: 100%;
                text-align: center;
            }

            .progress-ring {
                margin-left: auto;
            }

            .pdf-link {
                margin-left: auto;
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

            if (!orders || orders.length === 0) {
                html = `
                    <div class="text-center py-5">
                        <i class="bi bi-bag-x-fill"
                           style="font-size:70px;color:#c0c0c0;"></i>

                        <h4 class="mt-3 text-secondary">
                            No Orders Yet
                        </h4>

                        <p class="text-muted">
                            You haven't placed any orders yet.
                        </p>

                        <a href="/Admin/PlaceOrder.aspx"
                           class="btn btn-primary mt-2">
                            Place Your First Order
                        </a>
                    </div>
                `;

                $("#orderList").html(html);
                return;
            }

            orders.forEach(o => {
                let statusClass = "";
                let progress = 0;
                let progressColor = "#ff9800";
                if (o.OrderStatus === "Order Placed") {
                    statusClass = "status-placed";
                    progress = 0;
                    progressColor = "#ff9800";
                }
                else if (o.OrderStatus === "Order Approved") {
                    statusClass = "status-delivered";
                    progress = 20;
                    progressColor = "#2196f3";
                }
                else if (o.OrderStatus === "Design Approved") {
                    statusClass = "status-shipped";
                    progress = 40;
                    progressColor = "#4caf50";
                }
                else if (o.OrderStatus === "Production Started") {
                    statusClass = "status-shipped";
                    progress = 60;
                    progressColor = "#4caf50";
                }
                else if (o.OrderStatus === "Order Packed") {
                    statusClass = "status-shipped";
                    progress = 80;
                    progressColor = "#4caf50";
                }
                else if (o.OrderStatus === "Order Dispatched") {
                    statusClass = "status-shipped";
                    progress = 100;
                    progressColor = "#4caf50";
                }
                else if (o.OrderStatus === "Order Rejected") {
                    statusClass = "status-rejected";
                    progress = 100;
                    progressColor = "#f44336";
                }

                let tallyRefHtml = "";

                if (o.TallyRefNo && o.TallyRefNo.trim() !== "") {
                    tallyRefHtml = `
                        <span style="color:red;background: #f9fd0ad1;font-size:17px;">
                            <b>Work Order: ${o.TallyRefNo}</b>
                        </span>
                        <br/>
                    `;
                }

                html += `
                    <div class="order-card">

                        <div class="order-header" onclick="toggleOrder('${o.ID}')">

                            <span id="icon_${o.ID}">▼</span>

                            <div>
                                ${tallyRefHtml}
                                <b>Order ID: </b> ${o.OrderID}<br/>
                                <small>Placed on: ${o.CreatedDate}</small>
                            </div>

                            <div class="order-right">

                                <div class="order-status ${statusClass}">
                                    ${o.OrderStatus}
                                </div>

                                <a href="${o.AttachedPath ? '/Content/' + o.AttachedPath.replace('~/', '') : '#'}"
                                       target="_blank"
                                       onclick="event.stopPropagation();"
                                       title="${o.AttachedPath ? 'Attached Invoice' : 'No Invoice Available'}"
                                       class="pdf-link">

                                        <i class="bi bi-file-earmark-pdf-fill"
                                           style="color:${o.AttachedPath ? '#0d6efd' : '#888'}">
                                        </i>

                                    </a>

                               <div class="progress-ring">

                                <svg viewBox="0 0 40 40">

                                    <circle
                                        class="progress-bg"
                                        cx="20"
                                        cy="20"
                                        r="16">
                                    </circle>

                                    <circle
                                        class="progress-fill"
                                        cx="20"
                                        cy="20"
                                        r="16"
                                        stroke="${progressColor}"
                                        stroke-dasharray="100"
                                        stroke-dashoffset="${100 - progress}">
                                    </circle>

                                </svg>

                                <div class="progress-text"
                                     style="color:${progressColor}">
                                     ${progress}%
                                </div>

                            </div>

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
                        <a href="/Admin/PlaceOrder.aspx"><i>Product List</i></a>
                    </h2>
                </div>
                <br />
                <br />
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

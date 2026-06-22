    <%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="PlaceOrder.aspx.cs" Inherits="PlaceOrder" %>

    <%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
        <style type="text/css">
            .title-line {
                display: flex;
                align-items: center;
                margin: 10px 0;
            }

                .title-line::after {
                    content: "";
                    flex: 1;
                    height: 1px;
                    background: #000;
                    opacity: 0.4;
                }

            .header-row {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                padding: 10px 16px;
                flex-wrap: wrap; /* ✅ wraps on small screens */
                margin-bottom: 16px;
            }

            .header-right {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-left: auto;
                flex: 1; /* ✅ takes remaining space */
                justify-content: flex-end;
            }

            .search-box {
                flex: 1; /* ✅ stretches to fill available space */
                min-width: 120px; /* ✅ doesn't shrink too small */
                max-width: 300px;
                padding: 8px;
                border-radius: 7px;
                border: 2px solid black;
            }

            .product-container {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(242px, 1fr));
                gap: 8px;
                padding: 2px;
            }

            .product-card {
                border: 1px solid #ddd;
                border-radius: 7px;
                padding: 9px;
                box-shadow: 2px 4px 8px #1d4491c2;
                text-align: center;
                background: #9aa4b766;
            }

                .product-card img {
                    width: 93%;
                    height: 232px;
                    object-fit: cover;
                }

            .product-name {
                height: 48px;
                overflow: hidden;
                font-weight: 500;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
            }

            .btnCart {
                width: 50%;
                background: #2d69ea8f;
                color: #000000;
                border: none;
                padding: 3px;
                border-radius: 7px;
                margin-top: 1rem !important;
                font-weight: 700;
                margin-bottom: 1rem;
            }

            select {
                width: 100%;
                margin-top: 6px;
                padding: 4px;
                border-radius: 7px;
                border: 2px solid black;
                background-color: transparent;
            }

            input {
                width: 100%;
                margin-top: 13px;
                padding: 4px;
                border-radius: 7px;
                border: 2px solid black;
                background-color: transparent;
            }

            /* Image Popup */
            .img-modal {
                display: none;
                position: fixed;
                z-index: 99999;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.85);
                justify-content: center;
                align-items: center;
            }

                .img-modal img {
                    max-width: 90%;
                    max-height: 90%;
                    border-radius: 10px;
                    box-shadow: 0 0 20px rgba(0,0,0,0.5);
                    animation: zoomIn 0.2s ease-in-out;
                }

            @keyframes zoomIn {
                from {
                    transform: scale(0.7);
                    opacity: 0;
                }

                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            #customModal {
                display: none;
                position: fixed;
                z-index: 99999;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.85);
                justify-content: center;
                align-items: center;
            }

            /* ✅ Tablet */
            @media (max-width: 768px) {
                .product-container {
                    grid-template-columns: repeat(2, 1fr);
                }

                .product-card img {
                    height: 140px;
                }

                .search-box {
                    max-width: 100%;
                }
            }

            /* ✅ Mobile */
            @media (max-width: 480px) {
                .header-row {
                    padding: 8px;
                    gap: 8px;
                }

                    .header-row h2 {
                        font-size: 18px;
                    }

                .header-right {
                    width: 100%; /* ✅ full width row on mobile */
                    margin-left: 0;
                }

                .search-box {
                    max-width: 100%;
                    flex: 1;
                }

                .product-container {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 10px;
                }

                .product-card {
                    padding: 8px;
                }

                    .product-card img {
                        height: 120px;
                    }

                .product-name {
                    font-size: 14px;
                }

                .btnCart {
                    font-size: 12px;
                    padding: 6px;
                }
            }
        </style>
        <script type="text/javascript">
            let allProducts = [];

            window.onload = function () {

                loadCartData();
                loadProducts();

                document.getElementById("txtSearch").addEventListener("keyup", searchProducts);

            };

            function loadCartData() {

                fetch("PlaceOrder.aspx/GetCartData", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    }
                })
                    .then(r => r.json())
                    .then(data => {
                        var result = JSON.parse(data.d);  // result = [{ "Count": 3 }]
                        var count = result[0].Count;      // ✅ get the number

                        const badge = document.getElementById("cartCount");
                        if (count > 0) {
                            badge.innerText = count;
                            badge.style.display = "flex";
                        } else {
                            badge.style.display = "none";
                        }

                    });
            }

            function loadProducts() {

                fetch("PlaceOrder.aspx/GetProducts", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    }
                })
                    .then(r => r.json())
                    .then(data => {

                        allProducts = JSON.parse(data.d);
                        allProducts.forEach(function (p) {

                            if (p.ImagenamePath) {
                                p.ImagenamePath =
                                    p.ImagenamePath.replace("~/", "/Content/");
                            } else {
                                p.ImagenamePath = 'https://placehold.co/100x100?text=No-Image';
                            }

                        });

                        renderInitial();
                    });
            }

            function renderInitial() {

                let trending =
                    allProducts.filter(x => x.FavoriteProduct);

                let regular =
                    allProducts.filter(x => !x.FavoriteProduct);

                renderCards(
                    trending,
                    "trendingContainer"
                );

                renderCards(
                    regular,
                    "regularContainer"
                );
            }

            function searchProducts() {

                let text =
                    document.getElementById("txtSearch")
                        .value
                        .toLowerCase()
                        .trim();

                if (text === "") {

                    document.getElementById("divTrending").style.display = "block";
                    document.getElementById("divRegular").style.display = "block";
                    document.getElementById("divSearch").style.display = "none";

                    return;
                }

                document.getElementById("divTrending").style.display = "none";
                document.getElementById("divRegular").style.display = "none";
                document.getElementById("divSearch").style.display = "block";

                let filtered =
                    allProducts.filter(x =>
                        x.ProductName
                            .toLowerCase()
                            .includes(text)
                    );

                renderCards(
                    filtered,
                    "searchContainer"
                );
            }

            function renderCards(products, containerId) {

                let html = "";

                products.forEach(p => {

                    let is8x2Regular = p.Size === "8x2";
                    let is8x4Regular = p.Size === "8x4";

                    html += `

                <div class="product-card">

                    <img id="img_${p.ID}" 
                        src="${p.ImagenamePath}"
                        onclick="openModal('${p.ImagenamePath}')">

                    <div class="product-name" id="name_${p.ID}">
                        ${p.ProductName}
                    </div>

                    <select id="size_${p.ID}">
                        <option value="">Select Size</option>

                        <option value="8x2"  ${p.Size === "8x2" ? "selected" : ""}>
                            ${is8x2Regular ? "8x2 (Regular)" : "8x2 (Custom)"}
                        </option>

                        <option value="8x4"  ${p.Size === "8x4" ? "selected" : ""}>
                            ${is8x4Regular ? "8x4 (Regular)" : "8x4 (Custom)"}
                        </option>

                    </select>

                    <input id="qty_${p.ID}" autocomplete="off" placeholder="Quantity" onkeypress="return event.charCode >= 48 && event.charCode <= 57">

                  
                    <button
                        class="btnCart"
                        onclick="addToCart(${p.ID})">

                        Add To Cart

                    </button>
                </div>
                `;
                });

                document
                    .getElementById(containerId)
                    .innerHTML = html;
            }

            function addToCart(productId) {

                let size = document.getElementById("size_" + productId).value;
                let Textsize = document.getElementById("size_" + productId).options[
                    document.getElementById("size_" + productId).selectedIndex
                ].text.trim();

                let productType = Textsize.toLowerCase().includes("regular") ? "Regular" : "Custom";

                let qty = document.getElementById("qty_" + productId).value;
                let productName = document.getElementById("name_" + productId).innerText.trim();
                let imgN = document.getElementById("img_" + productId).src;
                imgN = "~/" + imgN.split("/Content/")[1];
                if (size === "") {

                    alert("Select Size");
                    window.location.href = window.location.href;
                    return;
                }

                if (qty === "" || qty <= 0) {

                    alert("Enter Quantity");
                    window.location.href = window.location.href;
                    return;
                }

                fetch("PlaceOrder.aspx/AddToCart", {

                    method: "POST",

                    headers: {
                        "Content-Type": "application/json"
                    },

                    body: JSON.stringify({
                        productId: productId,
                        productN: productName,
                        size: size,
                        productType: productType,
                        qty: qty,
                        imagename: imgN
                    })
                })
                    .then(r => r.json())
                    .then(() => {

                        alert("Added To Cart");
                        window.location.href = window.location.href;
                    });
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
    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
        <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="header-row">
                    <h2 class="fw-bold" style="margin: 0; white-space: nowrap;">Place Order</h2>

                    <div class="header-right">
                        <input type="text"
                            id="txtSearch"
                            class="search-box"
                            autocomplete="off"
                            placeholder="Search Product..." />

                        <div style="position: relative; display: inline-block; flex-shrink: 0;">
                            <asp:LinkButton type="button" class="btn" ID="lnkBtn" runat="server" OnClick="lnkBtn_Click">
                                <i class="bi bi-cart" style="font-size: 20px;"></i>
                            </asp:LinkButton>
                            <span id="cartCount" style="display: none; position: absolute; top: -6px; right: -6px; background: #e53935; color: #fff; font-size: 11px; font-weight: 600; min-width: 18px; height: 18px; border-radius: 50%; align-items: center; justify-content: center; padding: 0 3px;">0</span>
                        </div>
                    </div>
                </div>

                <div id="divTrending">

                    <div class="title-line"><i><b>Trending Products</b></i></div>

                    <div id="trendingContainer"
                        class="product-container">
                    </div>

                </div>

                <div id="divRegular">

                    <div class="title-line"><i><b>Regular Products</b></i></div>

                    <div id="regularContainer"
                        class="product-container">
                    </div>

                </div>

                <div id="divSearch"
                    style="display: none;">

                    <div class="title-line"><i><b>Search Results</b></i></div>

                    <div id="searchContainer"
                        class="product-container">
                    </div>

                </div>

                <div id="imgModal"
                    class="img-modal"
                    onclick="closeModal()">

                    <img id="modalImg">
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Content>

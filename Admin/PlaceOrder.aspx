<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="PlaceOrder.aspx.cs" Inherits="PlaceOrder" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.js"></script>

    <style type="text/css">
        /* ===== HEADER ===== */

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
            gap: 12px;
            padding: 14px 18px;
            border-radius: 14px;
            background: rgba(255,255,255,0.06);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-left: auto;
        }

        /* ===== SEARCH ===== */
        .search-box {
            flex: 1;
            min-width: 160px;
            max-width: 320px;
            padding: 10px 12px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.15);
            background: rgba(255,255,255,0.06);
            color: white;
            outline: none;
            transition: 0.25s;
        }

            .search-box:focus {
                border-color: #6ea8fe;
                box-shadow: 0 0 12px rgba(110,168,254,0.6);
            }

        /* ===== GRID ===== */
        .product-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 14px;
            padding: 10px;
        }

        /* ===== PRODUCT CARD (GLASS EFFECT) ===== */
        .product-card {
            position: relative;
            border-radius: 14px;
            padding: 12px;
            background: rgba(255,255,255,0.06);
            backdrop-filter: blur(14px);
            border: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 8px 25px rgba(0,0,0,0.35);
            text-align: center;
            transition: transform 0.25s, box-shadow 0.25s;
        }

            .product-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 12px 35px rgba(0,0,0,0.6);
            }

            /* ===== IMAGE ===== */
            .product-card img {
                width: 100%;
                height: 200px;
                object-fit: cover;
                border-radius: 10px;
                cursor: pointer;
                transition: 0.3s;
            }

                .product-card img:hover {
                    transform: scale(1.03);
                }

        /* ===== NAME ===== */
        .product-name {
            margin-top: 8px;
            font-weight: 600;
            font-size: 14px;
            height: 42px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            color: #000000;
        }

        /* ===== INPUTS ===== */
        select, input {
            width: 100%;
            margin-top: 10px;
            padding: 9px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.15);
            background: rgba(0,0,0,0.25);
            color: white;
            outline: none;
        }

            select:focus, input:focus {
                border-color: #6ea8fe;
                box-shadow: 0 0 10px rgba(110,168,254,0.5);
            }

        /* ===== BUTTON (NEON STYLE) ===== */
        .btnCart {
            width: 100%;
            margin-top: 12px;
            padding: 10px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-weight: 700;
            color: white;
            background: linear-gradient(135deg, #4f7cff, #7c4dff);
            box-shadow: 0 6px 18px rgba(124,77,255,0.35);
            transition: 0.25s;
        }

            .btnCart:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(124,77,255,0.5);
            }

        /* ===== BADGE ===== */
        #cartCount {
            background: linear-gradient(135deg, #ff3b3b, #ff0066);
            box-shadow: 0 0 10px rgba(255,0,102,0.5);
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

        @media (max-width: 480px) {
            .product-container {
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
            }

            .header-row {
                flex-direction: column;
                align-items: stretch;
            }

            .header-right {
                width: 100%;
                justify-content: space-between;
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
                        badge.innerText = "0";
                        badge.style.display = "flex";
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

            if (!trending || trending.length === 0) {
                document.getElementById("divTrending").style.display = "none";
            } else {
                document.getElementById("divTrending").style.display = "block";
            }
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

        function getconfirmation() {
            Swal.fire({
                title: 'Ready to Checkout?',
                html: `
            <div>
                Are you sure you don't want any more products?<br>
                You can continue shopping or proceed to your cart.
            </div>
        `,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Go to Cart',
                cancelButtonText: 'Keep Shopping',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = '/Admin/OrderList.aspx';
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="header-row">
                <h2 class="fw-bold" style="margin: 0; white-space: nowrap;">Product List</h2>

                <div class="header-right">
                    <input type="text"
                        id="txtSearch"
                        class="search-box"
                        autocomplete="off"
                        placeholder="Search Product..." />

                    <div style="position: relative; display: inline-block; flex-shrink: 0;">
                        <button type="button" class="btn" onclick="getconfirmation()">
                            <i class="bi bi-cart" style="font-size: 20px;"></i>
                        </button>
                        <span id="cartCount" style="display: none; position: absolute; top: -6px; right: -6px; background: #e53935; color: #fff; font-size: 11px; font-weight: 600; min-width: 18px; height: 18px; border-radius: 50%; align-items: center; justify-content: center; padding: 0 3px;">0</span>
                    </div>
                </div>
            </div>
            <br />
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

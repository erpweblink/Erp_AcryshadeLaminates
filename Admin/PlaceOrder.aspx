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

                    <div style="display:flex; gap:8px; justify-content:center; margin-top:10px;">
                    <button
                        class="btnCart"
                        onclick="addToCart(${p.ID})">

                        Add To Cart

                    </button>

                    <button
                        class="btnCart"
                        style="background:#ff9800; flex:1; margin-top:5px"
                         onclick="openCustomizeModal(${p.ID}, '${p.ProductName.replace(/'/g, "\\'")}','${p.Size}','${p.ImagenamePath}'); return false;">

                        Customize
                    </button>
                    </div>
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

            function openCustomizeModal(id, name, size, prodImageName) {

                document.getElementById("customModal").style.display = "flex";

                document.getElementById("custProductId").value = id;

                document.getElementById("prodImageName").value = prodImageName;

                document.getElementById("custProductName").innerText = name;

                document.getElementById("custFile").value = "";

                document.getElementById("custNote").value = "";

                let ddl = document.getElementById("custSize");


                ddl.innerHTML = "";

                ddl.innerHTML += `<option value="">Select Size</option>`;

                let is8x2Regular = size === "8x2";
                let is8x4Regular = size === "8x4";

                ddl.innerHTML += `
                    <option value="8x2">
                        ${is8x2Regular ? "8x2 (Regular)" : "8x2 (Custom)"}
                    </option>
                `;

                ddl.innerHTML += `
                    <option value="8x4">
                        ${is8x4Regular ? "8x4 (Regular)" : "8x4 (Custom)"}
                    </option>
                `;

                // auto-select
                ddl.value = size || "";
            }

            function closeCustomizeMod() {
                document.getElementById("customModal").style.display = "none";
                window.location.href = window.location.href;
            }

            function submitCustomize() {
                let id = document.getElementById("custProductId").value;
                let size = document.getElementById("custSize").value;
                let cutqty = document.getElementById("cutqty").value.trim();
                let note = document.getElementById("custNote").value;
                let prodImageName = document.getElementById("prodImageName").value;
                let file = document.getElementById("custFile").files[0];

                if (size === "") {
                    alert("Please select size");
                    window.location.href = window.location.href;
                    return;
                }
                if (cutqty === "") {
                    alert("Please Enter Qty");
                    window.location.href = window.location.href;
                    return;
                }
             

                // ✅ If file selected, convert to Base64 then send
                if (file) {
                    let reader = new FileReader();
                    reader.onload = function (e) {
                        let base64 = e.target.result; 
                        sendCustomization(id, size, cutqty, note, prodImageName, base64, file.name);
                    };
                    reader.readAsDataURL(file);
                } else {
                    sendCustomization(id, size, cutqty, note, prodImageName, null, null);
                }
            }

            function sendCustomization(id, size, cutqty, note, prodImageName, base64File, fileName) {
                fetch("PlaceOrder.aspx/SaveCustomization", {
                    method: "POST",
                    credentials: "same-origin",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        productId: id,
                        size: size,
                        qty: cutqty,
                        note: note,
                        prodImagName: prodImageName,
                        fileBase64: base64File,   // ✅ Base64 string
                        fileName: fileName         // ✅ original file name
                    })
                })
                    .then(r => {
                        // ✅ Check if response is actually JSON before parsing
                        const contentType = r.headers.get("content-type");
                        if (!contentType || !contentType.includes("application/json")) {
                            throw new Error("Server returned HTML instead of JSON. Check your WebMethod.");
                        }
                        return r.json();
                    })
                    .then(() => {
                        alert("Customization submitted");
                        closeCustomizeMod();
                    })
                    .catch(err => {
                        console.error("Error:", err.message);
                        alert("Something went wrong: " + err.message);
                    });
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
                            <button type="button" class="btn" onclick="toggleCartDropdown()">
                                <i class="bi bi-cart" style="font-size: 20px;"></i>
                            </button>
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

                <div id="customModal"
                    class="img-modal"
                    style="display: none; flex-direction: column; padding: 20px;">

                    <div style="background: #7b8eaf; border: 2px solid #9aa4b766; padding: 20px; border-radius: 10px; min-width: 300px;">

                        <h3 id="custProductName" style="color: whitesmoke;"></h3>

                        <input type="hidden" id="custProductId">
                        <input type="hidden" id="prodImageName">

                        <select id="custSize" style="width: 100%; margin-top: 10px; background: whitesmoke;">
                        </select>


                        <input id="cutqty" placeholder="Qty" style="width: 100%; margin-top: 10px; background: whitesmoke;"  onkeypress="return event.charCode >= 48 && event.charCode <= 57"/>

                        <input type="file"
                            id="custFile"
                            accept=".jpg,.jpeg,.png"
                            style="margin-top: 10px; background: whitesmoke;">

                        <textarea id="custNote"
                            placeholder="Write your customization note..."
                            style="width: 100%; margin-top: 10px; height: 80px;"></textarea>

                        <div style="margin-top: 15px; text-align: right">

                            <button onclick="closeCustomizeMod()" style="background: red; color: white">Close</button>

                            <button onclick="submitCustomize()"
                                style="background: green; color: white">
                                Add To Cart
                            </button>

                        </div>

                    </div>

                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Content>

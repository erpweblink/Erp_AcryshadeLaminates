<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="OrderList.aspx.cs" Inherits="OrderList" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style>
        .card {
            border-radius: 16px;
        }

        .table thead th {
            font-weight: 600;
            border: none;
        }

        .table tbody tr {
            transition: .25s;
        }

            .table tbody tr:hover {
                background: #f8fbff;
            }

        .product-image-preview {
            width: 100px;
            height: 100px;
            border-radius: 12px;
            object-fit: cover;
            border: 2px solid #e9ecef;
            transition: .3s;
        }

            .product-image-preview:hover {
                transform: scale(1.08);
            }

        .qty {
            text-align: center;
            font-weight: 600;
        }

        .sticky-top {
            z-index: 10;
        }


        /* ===== FULL SCREEN LOADER ===== */
        #pageLoader {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.6);
            backdrop-filter: blur(6px);
            z-index: 99999;
            justify-content: center;
            align-items: center;
        }
        /* optional styling for link h2 */
        .product-link a {
            text-decoration: none;
            font-size: 16px;
        }

        /* ===== SPINNER ===== */
        .loader-ring {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 4px solid rgba(255,255,255,0.1);
            border-top: 4px solid #4f7cff;
            border-right: 4px solid #7c4dff;
            animation: spin 1s linear infinite;
            box-shadow: 0 0 25px rgba(79,124,255,0.6);
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        /* glow text */
        .loader-text {
            margin-top: 15px;
            color: #fff;
            font-weight: 600;
            letter-spacing: 1px;
            text-align: center;
            font-size: 14px;
            animation: pulse 1.2s infinite;
        }

        @keyframes pulse {
            0%,100% {
                opacity: 0.6;
            }

            50% {
                opacity: 1;
            }
        }
    </style>
    <script>
        function showLoader() {
            document.getElementById("pageLoader").style.display = "flex";
        }

        function loadWorkOrderData(data) {
            var totalProducts = 0;
            var totalQty = 0;

            $('#tblRawMaterial tbody').html('');
            $.each(data, function (index, item) {
                totalProducts++;
                totalQty += parseInt(item.Qty || 0);

                var row = '';

                row += '<tr style="transition: 0.3s;">';

                row += '<td class="srno text-center" style="width:10px;border:1px solid #e3e6f0;padding:6px;font-weight:600;">' + (index + 1) + '</td>';

                //Upload image
                const imageUrl = item.ImagePathName && item.ImagePathName.trim() !== 'null'
                    ? item.ImagePathName.replace('~/', '/Content/')
                    : 'https://placehold.co/100x100?text=Image';

                var type = item.ProductType;

                row += '<td class="text-center">' +
                    '<div class="d-flex flex-column align-items-center">' +

                    `<img src="${imageUrl}" class="product-image-preview mb-2" />` +

                    (type === "Custom"
                        ? '<button type="button" class="btn btn-outline-primary btn-sm upload-btn">' +
                        '<i class="bi bi-camera-fill"></i> Upload' +
                        '</button>' +
                        '<input type="file" ' +
                        'name="ProductImage[]" ' +
                        'class="file-input d-none" ' +
                        'accept="image/*" />'
                        : '') +

                    '<input type="hidden" value="' + item.ImagePathName + '" name="ProdImageName[]" />' +

                    '</div>' +
                    '</td>';

                // Product Name
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<textarea  name = "ProductName[]" autocomplete = "off" readonly="true" ' +
                    'class="form-control productname" ' +
                    'style = "border-radius: 8px; height: 80px; min-width: 150px;" >' + item.ProductName + '</textarea>' +
                    '<input type="hidden" name="ProductId[]" class="productid" value="' + item.ProductID + '"/></td>';

                var productNote = item.ProductNote == null ? '' : item.ProductNote;

                //Description
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<textarea name="Description[]" autocomplete="off" ' +
                    'class="form-control description"' +
                    'style="border-radius: 8px; height: 80px; min-width: 150px;">' +
                    productNote +
                    '</textarea>' +
                    '</td>';

                //Type
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<input  name="Type[]"  readonly="true" ' +
                    'class="form-control typ" ' +
                    'value="' + item.ProductType + '" ' +
                    'style="border-radius: 8px; height: 42px; min-width: 20px;" />' +
                 '</td>';


                //Size
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">';
                row += '<select name="Size[]" class="form-control size readonly-select" ' +
                    'style="border-radius: 8px; height: 42px; min-width: 30px;">';
                row += '<option value="">-- Select Size --</option>';
                row += ' <option value="8x2"' + (item.Size == '8x2' ? ' selected' : '') + '>8x2</option>';
                row += '  <option value="8x4"' + (item.Size == '8x4' ? ' selected' : '') + '>8x4</option>';
                row += '</select>';
                row += '</td>';


                // Qty
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<input type="number" ' +
                    'name="Qty[]" ' +
                    'class="form-control qty" ' +
                    'value="' + (item.Qty > 0 ? item.Qty : 1) + '" ' +
                    'min="1" ' +
                    'onkeypress="return event.charCode >= 48 && event.charCode <= 57" ' +
                    'oninput="if(this.value==0) this.value=1;" ' +
                    'onblur="if(this.value==\'\' || parseInt(this.value)<=0) this.value=1;" ' +
                    'onchange="updateSummary()"'+
                    'style="border-radius: 8px; height: 42px; min-width: 20px;" />' +
                    '</td>';


                row += '<input type="hidden" name="rowid[]" class="rowid" value="' + item.ID + '" />';

                row += `<td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">
                     <button type="button" class="btnRm" style="border:none;background:none;cursor:pointer;">
                        <i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>
                     </button>
                 </td>`;

                row += '</tr>';

                $('#tblRawMaterial tbody').append(row);
            });
            $('#productCount').text(totalProducts);
            $('#summaryProducts').text(totalProducts);
            $('#summaryQty').text(totalQty);
        }

        $(document).on('mousedown', '.readonly-select', function (e) {
            e.preventDefault();
        });

        $(document).on('click', '.upload-btn', function () {
            $(this).closest('div').find('.file-input').click();
        });

        $(document).on('change', '.file-input', function () {

            const file = this.files[0];

            if (file) {

                const reader = new FileReader();

                const img = $(this)
                    .closest('div')
                    .find('.product-image-preview');

                reader.onload = function (e) {
                    img.attr('src', e.target.result);
                };

                reader.readAsDataURL(file);
            }
        });

        $(document).on('click', '.btnRm', function () {

            var row = $(this).closest('tr');
            var id = row.find('.rowid').val();

            if (!confirm('Are you sure you want to delete this item?')) {
                return;
            }

            $.ajax({
                type: "POST",
                url: "OrderList.aspx/DeleteTempOrder",
                data: JSON.stringify({ id: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    if (response.d === "Success") {
                        row.remove();
                        updateSummary();
                    }
                    else {
                        alert(response.d);
                    }
                },
                error: function (xhr) {
                    alert("Error deleting record");
                    console.log(xhr.responseText);
                }
            });
        });

        function updateSummary() {

            var totalProducts = 0;
            var totalQty = 0;

            $('#tblRawMaterial tbody tr').each(function () {

                totalProducts++;

                var qty = parseInt($(this).find('.qty').val()) || 1;
                totalQty += qty;
            });

            $('#productCount').text(totalProducts);
            $('#summaryProducts').text(totalProducts);
            $('#summaryQty').text(totalQty);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div id="pageLoader">
                <div style="text-align: center;">
                    <div class="loader-ring"></div>
                    <div class="loader-text">Placing Order...</div>
                </div>
            </div>

            <!-- Order Header -->

            <div class="container-fluid py-4">
                <div class="card border-0 shadow-lg mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h2 class="fw-bold text-primary mb-1">
                                    <i class="bi bi-cart-check-fill"></i>
                                    Place Order
                                </h2>

                                <p class="text-muted mb-0">
                                    Review products, upload custom products and confirm your order.
                                </p>
                                <a class="product-link" href="/Admin/PlaceOrder.aspx"><i>Back to Products </i></a>
                            </div>

                            <div>
                                <span class="badge bg-primary fs-6 p-3">Total Products :
                                 <span id="productCount">0</span>
                                </span>

                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Order Summary -->
                    <div class="col-lg-3">
                        <div class="card border-0 shadow sticky-top"
                            style="top: 20px;">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">
                                    <i class="bi bi-receipt"></i>
                                    Order Summary
                                </h5>
                            </div>

                            <div class="card-body">
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between">
                                        <span>Total Products</span>
                                        <strong id="summaryProducts">0</strong>
                                    </div>
                                </div>
                                <hr />
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between">
                                        <span>Total Quantity</span>
                                        <strong id="summaryQty">0</strong>
                                    </div>
                                </div>
                                <hr />
                                <div>
                                    <asp:Label ID="lblMCImage" runat="server" CssClass="form-label">Attach Order <span class="text-danger mt-1">(.pdf)</span>:</asp:Label>
                                    <asp:FileUpload ID="FileMCImage" runat="server" CssClass="form-control" accept=".pdf" />
                                    <small class="text-danger d-block mt-1">Maximum file size: 50 MB</small>
                                </div>
                                <br />
                                <div class="alert alert-info">
                                    <i class="bi bi-info-circle"></i>
                                    Please verify all artwork, sizes and quantities before submitting the order.
                                </div>
                                <div class="d-grid">
                                    <asp:LinkButton
                                        ID="btnsave"
                                        runat="server"
                                        CssClass="btn btn-success btn-lg shadow"
                                        OnClick="btnsave_Click" OnClientClick="showLoader();">

                     <i class="bi bi-cart-check-fill"></i>
                     Place Order
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-9">
                        <div class="card border-0 shadow">
                            <div class="card-header py-3">
                                <h5 class="mb-0 fw-bold">
                                    <i class="bi bi-box-seam"></i>
                                    Order Items
                                </h5>
                            </div>

                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table id="tblRawMaterial"
                                        class="table table-hover align-middle mb-0">
                                        <thead class="table-primary text-center">
                                            <tr>
                                                <th width="10">#</th>
                                                <th width="140">Image</th>
                                                <th>Product</th>
                                                <th>Description</th>
                                                <th width="50">Type</th>
                                                <th width="30">Size</th>
                                                <th width="30">Qty</th>
                                                <th width="30">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnsave" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

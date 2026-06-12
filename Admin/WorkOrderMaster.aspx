<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" Async="true" CodeFile="WorkOrderMaster.aspx.cs" Inherits="WorkOrderMaster" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">

    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <style type="text/css">
        .spncls {
            color: red;
        }

        .completionList {
            scroll-behavior: smooth;
            border: solid 1px Gray;
            border-radius: 0 0 6px 6px;
            margin: 0px;
            padding: 3px;
            height: 200px;
            overflow: auto;
            width: 500px;
            background-color: #FFFFFF;
            font-size: 16px;
        }

        .listItem {
            color: #191919;
        }

        .itemHighlighted {
            background-color: #5b78b1;
            font-weight: 900;
        }

        .error-border {
            border: 2px solid red !important;
        }

        .error-msg {
            min-height: 14px;
            margin-top: 2px;
        }


        .highlight-checkbox {
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .highlight-checkbox input[type="checkbox"] {
                width: 17px;
                height: 17px;
                accent-color: #28a745; /* Green checkbox */
                cursor: pointer;
                justify-items: center;
                align-items: baseline;
            }

            .highlight-checkbox label {
                font-size: 12px;
                font-weight: bold;
                color: #198754;
                background-color: #d1e7dd;
                padding: 1px 5px;
                border-radius: 4px;
                cursor: pointer;
            }
    </style>

    <script type="text/javascript">

        $(document).on('focus', '.productname', function () {
            var $input = $(this);
            bindProductAutocomplete($input);
        });

        function bindProductAutocomplete($input) {
            if ($input.data('ui-autocomplete')) return;

            $input.autocomplete({
                minLength: 1,
                source: function (request, response) {
                    $.ajax({
                        url: 'WorkOrderMaster.aspx/GetProductAutoComplete',
                        type: 'POST',
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        data: JSON.stringify({ prefixText: request.term }),
                        success: function (data) {
                            let result = data.d || [];
                            response($.map(result, function (item) {
                                return {
                                    label: item.ProductName,
                                    value: item.ProductName,
                                    id: item.ProductId,
                                    partNo: item.PartNo,
                                    size: item.Size
                                };
                            }));
                        }
                    });
                },
                select: function (event, ui) {
                    var row = $(this).closest('tr');
                    row.find('input[name="ProductId[]"]').val(ui.item.id);
                    row.find('input[name="ProductName[]"]').val(ui.item.value);
                    row.find('input[name="SheetNo[]"]').val(ui.item.partNo);
                    row.find('select[name="Size[]"]').val(ui.item.size);

                    return false;
                }
            });
        }

        $(document).ready(function () {

            updateSerialNumbers();

            // ADD NEW ROW
            $(document).on('click', '.btnAdd', function () {

                var lastRow = $('#tblRawMaterial tbody tr:last');
                if (!validateRow(lastRow)) return;

                // Get values from last row
                var productName = lastRow.find('[name="ProductName[]"]').val().trim();
                var itemCode = lastRow.find('[name="SheetNo[]"]').val().trim();
                var size = lastRow.find('[name="Size[]"]').val();

                if (productName && productName.trim() !== '') {
                    SaveProductMaster(productName, itemCode, size);
                }

                // Convert current add button to delete
                $(this)
                    .removeClass('btnAdd')
                    .addClass('btnDelete')
                    .attr('style', 'border:none!important;background:none!important')
                    .html('<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>');

                // Create new row
                var newRow = `  <tr style="transition: 0.3s;">
                <!-- Sr No -->
                 <td class="srno text-center"
                     style="border: 1px solid #e3e6f0; padding: 10px; font-weight: 600;">1
                 </td>

                 <!-- Product Name -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text"
                         name="ProductName[]"
                         autocomplete="off"
                         class="form-control productname"
                         style="border-radius: 8px; height: 42px; min-width: 150px;" />
                     <div class="error-msg productname-error text-danger" style="font-size: 12px;"></div>
                     <input type="hidden" name="ProductId[]" class="productid" />
                 </td>

                 <!-- Sheet No -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="SheetNo[]" autocomplete="off"
                         class="form-control sheetno"
                         rows="2"
                         style="border-radius: 8px; min-width: 120px; resize: none;" />
                     <div class="error-msg sheetno-error text-danger" style="font-size: 12px;"></div>
                 </td>

                    <!-- Type -->
                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                       <select name="Type[]"
                           class="form-control typo"
                           style="border-radius: 8px; min-width: 120px; resize: none;" >
                           <option value="Regular" selected>Regular</option>
                           <option value="Custom">Custom</option>
                       </select>
                       <div class="error-msg typo-error text-danger" style="font-size: 12px;"></div>
                   </td>

                 <!-- Description -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <textarea
                         name="Description[]" autocomplete="off"
                         class="form-control description"
                         style="border-radius: 8px; height: 42px; min-width: 200px;" ></textarea>
                     <div class="error-msg description-error text-danger" style="font-size: 12px;"></div>
                 </td>

                 <!-- Size -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <select name="Size[]"
                         class="form-control size"
                         style="border-radius: 8px; height: 42px; min-width: 120px;" onchange="GetSQFeet(this)">
                         <option value="">-- Select Size --</option>
                         <option value="2x4">2 x 4</option>
                         <option value="2x8">2 x 8</option>
                         <option value="4x8">4 x 8</option>
                     </select>
                     <div class="error-msg size-error text-danger" style="font-size: 12px;"></div>
                 </td>

                 <!-- Qty -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="number"
                         step="0.01"
                         name="Qty[]"
                         class="form-control qty"
                         style="border-radius: 8px; height: 42px; min-width: 70px;" oninput="GetSQFeet(this)"/>
                     <div class="error-msg qty-error text-danger" style="font-size: 12px;"></div>
                 </td>

                  <!-- Sq Feet -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="SqFeet[]" readonly="readonly" class="form-control sqfeet"
                         style="border-radius: 8px; height: 42px; min-width: 60px;" />
                     <div class="error-msg sqfeet-error text-danger" style="font-size: 12px;"></div>
                 </td>

                 <!-- Unit -->
                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="Unit[]" value="NOS" readonly="readonly" class="form-control unit"
                         style="border-radius: 8px; height: 42px; min-width: 70px;" />
                     <div class="error-msg unit-error text-danger" style="font-size: 12px;"></div>
                 </td>

                   <!-- Upload Image -->
                  <td style="border: 1px solid #e3e6f0; padding: 8px;">
                      <div class="position-relative d-inline-block">

                          <img src="https://placehold.co/100x100?text=Image"
                              class="product-image-preview"
                              style="width: 70px; height: 70px; object-fit: cover; border: 1px solid #ddd; border-radius: 8px;" />

                          <a href="javascript:void(0);"
                              class="upload-btn position-absolute bottom-0 end-0 rounded-circle text-white border border-white shadow"
                              style="background:rgb(89 118 175); width: 27px;height: 26px;display: flex; align-items: center; justify-content: center; font-size: 13px; cursor: pointer;">
                              <i class="bi bi-camera"></i>
                          </a>

                          <input type="file"
                              name="ProductImage[]"
                              class="file-input"
                              accept="image/*"
                              style="display: none;" />

                              <input type="hidden" name="ProdImageName[]" class="file-input" />
                      </div>


                      <div class="error-msg productimage-error text-danger"
                          style="font-size: 12px;">
                      </div>
                  </td>

                <!-- Action -->
                <td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">
                    <button type="button" class="btnAdd" style="border:none;background:none;cursor:pointer;">
                        <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px;"></i>
                    </button>
                </td>
            </tr>
        `;

                $('#tblRawMaterial tbody').append(newRow);
                bindProductAutocomplete($('#tblRawMaterial tbody tr:last .productname'));

                updateSerialNumbers();
            });

            // DELETE ROW
            $(document).on('click', '.btnDelete', function () {
                $(this).closest('tr').remove();
                updateSerialNumbers();

            });

            function SaveProductMaster(productName, itemCode, size) {
                $.ajax({
                    type: "POST",
                    url: "WorkOrderMaster.aspx/SaveProductMaster",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        ProductName: productName,
                        ItemCode: itemCode,
                        Size: size
                    }),
                    success: function (response) {
                    
                        if (response.d === "Success") {
                            alert("New Product Created");
                        }
                    },
                    error: function (xhr) {
                        console.log(xhr.responseText);
                    }
                });
            }

        });

        // SERIAL NUMBER FUNCTION
        function updateSerialNumbers() {
            $('#tblRawMaterial tbody tr').each(function (index) {
                $(this).find('.srno').text(index + 1);
            });
        }

        // VALIDATE ROW
        function validateRow(row) {
            let isValid = true;

            row.find('.error-msg').text('');
            row.find('input,select,textarea').removeClass('error-border');

            const fields = [
                { selector: '[name="ProductName[]"]', msg: 'Product Name is required' },
                { selector: '[name="SheetNo[]"]', msg: 'Item Code is required' },
                { selector: '[name="Size[]"]', msg: 'Size is required' },
                { selector: '.qty', msg: 'Enter valid Qty' }
            ];

            // Validate common fields
            fields.forEach(f => {
                let el = row.find(f.selector);

                if (el.val() === '' || (el.hasClass('qty') && parseFloat(el.val()) <= 0)) {
                    el.addClass('error-border');
                    el.next('.error-msg').text(f.msg);
                    isValid = false;
                }
            });

            // Validate Description only when Type = Custom
            let type = row.find('[name="Type[]"]').val();

            if (type === "Custom") { // or "Custom" if you correct the option value
                let desc = row.find('[name="Description[]"]');

                if ($.trim(desc.val()) === '') {
                    desc.addClass('error-border');
                    desc.next('.error-msg').text('Description is required');
                    isValid = false;
                }
            }

            return isValid;
        }

        function DealerSelected(source, eventArgs) {
            var dealerId = eventArgs.get_value();
            document.getElementById('<%= hdnDealerId.ClientID %>').value = dealerId;
            $find('<%= AutoCompleteExtender2.ClientID %>').set_contextKey(dealerId);

            $.ajax({
                type: "POST",
                url: "WorkOrderMaster.aspx/GetDealersInfo",
                data: JSON.stringify({ dealerId: dealerId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var BillingAddress = $("#<%= txtBillingAddress.ClientID %>");
                    var BillGst = $("#<%= txtBillGst.ClientID %>");
                    var BillPinCode = $("#<%= txtBillPinCode.ClientID %>");

                    BillingAddress.val(response.d[0]);
                    BillPinCode.val(response.d[1]);
                    BillGst.val(response.d[2]);
                },
                error: function (xhr) {
                    //console.log(xhr.responseText);
                }
            });
        }

        function CompanyData(source, eventArgs) {
            var companyId = eventArgs.get_value();
            $.ajax({
                type: "POST",
                url: "WorkOrderMaster.aspx/GetShippingAddresses",
                data: JSON.stringify({ companyId: companyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var ddl = $("#<%= ddlShipAddress.ClientID %>");

                    ddl.empty();
                    ddl.append('<option value="">--Select Shipping Address--</option>');

                    $.each(response.d, function (i, item) {

                        var arr = item.split('|');

                        ddl.append(
                            $('<option></option>')
                                .val(arr[0])
                                .text(arr[1])
                        );
                    });
                },
                error: function (xhr) {
                    //console.log(xhr.responseText);
                }
            });
        }

        function GetShippingDetails() {
            var shippingId = $("#<%= ddlShipAddress.ClientID %>").val();
            if (shippingId == "")
                return;

            $.ajax({
                type: "POST",
                url: "WorkOrderMaster.aspx/GetShippingDetails",
                data: JSON.stringify({ shippingId: shippingId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d.length > 0) {
                        var arr = response.d[0].split('|');
                        $("#<%= hdnShipAddressId.ClientID %>").val(arr[0]);
                        $("#<%= txtShipPinCode.ClientID %>").val(arr[1]);
                        $("#<%= txtShipGst.ClientID %>").val(arr[2]);
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        $(document).on('change', '#check_address', function () {
            if ($(this).is(':checked')) {
                var DealerId = $("#<%= hdnDealerId.ClientID %>").val();
                var DealerName = $("#<%= txtDealerName.ClientID %>").val();
                if (DealerId == "")
                    return;

                $.ajax({
                    type: "POST",
                    url: "WorkOrderMaster.aspx/GetDealersInfo",
                    data: JSON.stringify({ dealerId: DealerId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var ddl = $("#<%= ddlShipAddress.ClientID %>");

                        ddl.empty();
                        ddl.append('<option value="">--Select Shipping Address--</option>');

                        if (response.d.length > 0) {
                            ddl.append('<option value="' + response.d[3] + '">' + response.d[3] + '</option>');
                            ddl.val(response.d[3]);
                            $("#<%= hdnShipAddressId.ClientID %>").val(response.d[3]);
                            $("#<%= ddlShipAddress.ClientID %>").prop('disabled', true);

                            $("#<%= txtCustName.ClientID %>").val(DealerName);
                            $("#<%= txtShipPinCode.ClientID %>").val(response.d[4]);
                            $("#<%= txtShipGst.ClientID %>").val(response.d[2]);

                            $("#<%= txtCustName.ClientID %>").prop('readonly', true);
                            $("#<%= txtShipPinCode.ClientID %>").prop('readonly', true);
                            $("#<%= txtShipGst.ClientID %>").prop('readonly', true);
                        }
                    },
                    error: function (xhr) {
                        console.log(xhr.responseText);
                    }
                });
            } else {
                var ddl = $("#<%= ddlShipAddress.ClientID %>");

                ddl.empty();
                ddl.append('<option value="">--Select Shipping Address--</option>');

                $("#<%= hdnShipAddressId.ClientID %>").val('');


                $("#<%= txtCustName.ClientID %>").val('');
                $("#<%= txtShipPinCode.ClientID %>").val('');
                $("#<%= txtShipGst.ClientID %>").val('');

                $("#<%= txtCustName.ClientID %>").prop('readonly', false);
                $("#<%= txtShipPinCode.ClientID %>").prop('readonly', false);
                $("#<%= txtShipGst.ClientID %>").prop('readonly', false);

                ////$("#<%= ddlShipAddress.ClientID %>").prop('disabled', false);
            }
        });

        function loadWorkOrderData(data) {     
            $('#tblRawMaterial tbody').html('');
            $('#check_address').prop('disabled', true);
            $.each(data, function (index, item) {

                var btnHtml = '';

                if (index == data.length - 1) {
                    btnHtml =
                        '<button  type="button" class="btnAdd" style="border: none; background: none; cursor: pointer;">' +
                        '<i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>' +
                        '</button>';
                }
                else {
                    btnHtml =
                        '<button type="button" class="btnDelete" style="border: none; background: none; cursor: pointer;">' +
                        '<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>' +
                        '</button>';
                }

                var row = '';

                row += '<tr style="transition: 0.3s;">';

                row += '<td class="srno text-center"  style="border:1px solid #e3e6f0;padding: 10px;font-weight: 600;">' + (index + 1) + '</td>';

                // Product Name
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<input type = "text" name = "ProductName[]" autocomplete = "off" ' +
                    'class="form-control productname" ' +
                    'value="' + item.ProductName + '" ' +
                    'style = "border-radius: 8px; height: 42px; min-width: 150px;" />' +
                    '<div class="error-msg productname-error text-danger" style="font-size: 12px;"></div>' +
                    '<input type="hidden" name="ProductId[]" class="productid" value="' + item.ProductId + '"/></td>';

                // Sheet No
                row += ' <td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    ' <input type="text" name="SheetNo[]"  autocomplete="off" ' +
                    'class="form-control sheetno" rows="2" ' +
                    'value="' + item.PartNo + '" ' +
                    ' style="border-radius: 8px; min-width: 120px; resize: none;" />' +
                    ' <div class="error-msg sheetno-error text-danger" style="font-size: 12px;"></div>' +
                    '</td>';

                //Type 
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<select name="Type[]" ' +
                    'class="form-control typo" ' +
                    'style="border-radius: 8px; min-width: 120px; resize: none;" >' +
                    '<option value="Regular" ' + (item.Type == 'Regular' ? ' selected' : '') + '>Regular</option>' +
                    '<option value="Custom"' + (item.Type == 'Custom' ? ' selected' : '') + '>Custom</option>' +
                    '</select>' +
                    '<div class="error-msg typo-error text-danger" style="font-size: 12px;"></div>' +
                    '</td>';

                //Description
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<textarea name="Description[]" autocomplete="off" ' +
                    'class="form-control description"' +
                    'style="border-radius: 8px; height: 42px; min-width: 200px;">' +
                    item.Description +
                    '</textarea>' +
                    ' <div class="error-msg description-error text-danger" style="font-size: 12px;"></div>' +
                    '</td>';

                //Size
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">';
                row += '<select name="Size[]" class="form-control size" ' +
                    'style="border-radius: 8px; height: 42px; min-width: 120px;"  onchange="GetSQFeet(this)">';
                row += '<option value="">-- Select Size --</option>';
                row += ' <option value="2x4"' + (item.Size == '2x4' ? ' selected' : '') + '>2 x 4</option>';
                row += ' <option value="2x8"' + (item.Size == '2x8' ? ' selected' : '') + '>2 x 8</option>';
                row += '  <option value="4x8"' + (item.Size == '4x8' ? ' selected' : '') + '>4 x 8</option>';
                row += '</select>';
                row += ' <div class="error-msg size-error text-danger" style="font-size: 12px;"></div>';
                row += '</td>';


                //Qty
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<input type="number" step="0.01" name="Qty[]" ' +
                    'class="form-control qty" ' +
                    'value="' + item.Qty + '" ' +
                    'style="border-radius: 8px; height: 42px; min-width: 70px;" oninput="GetSQFeet(this)"/>' +
                    '<div class="error-msg qty-error text-danger" style="font-size: 12px;"></div>' +
                    '</td>';

                //Sq Feet
                row += '<td style = "border: 1px solid #e3e6f0; padding: 8px;" >' +
                    '<input type="text" name="SqFeet[]" readonly="readonly" value="' + item.SqFeet + '" class="form-control sqfeet"' +
                    'style = "border-radius: 8px; height: 42px; min-width: 60px;" /> ' +
                    '<div class="error-msg sqfeet-error text-danger" style = "font-size: 12px;" ></div > ' +
                    '</td >';

                //Unit
                row += '<td style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    '<input type="text" name="Unit[]" value="NOS" readonly="readonly" class="form-control unit" ' +
                    'style="border-radius: 8px; height: 42px; min-width: 70px;"/>' +
                    ' <div class="error-msg unit-error text-danger" style="font-size: 12px;"></div>' +
                    '</td>';

                const imageUrl = item.UploadedImage && item.UploadedImage.trim() !== 'null'
                    ? item.UploadedImage.replace('~/', '/Content/')
                    : 'https://placehold.co/100x100?text=Image';
            

                // '<img src="https://placehold.co/100x100?text=Image"' +
                //Upload image
                row += '<td style = "border: 1px solid #e3e6f0; padding: 8px;" > ' +
                    '<div class="position-relative d-inline-block">' +
              
                    `<img src="${imageUrl}" ` +
                    'class="product-image-preview" ' +
                    'style="width: 70px; height: 70px; object-fit: cover; border: 1px solid #ddd; border-radius: 8px;" />' +

                    '<a href="javascript:void(0);" ' +
                    'class="upload-btn position-absolute bottom-0 end-0 rounded-circle text-white border border-white shadow" ' +
                    'style="background:rgb(89 118 175); width: 27px;height: 26px;display: flex; align-items: center; justify-content: center; font-size: 13px; cursor: pointer;"> ' +
                    '<i class="bi bi-camera"></i>' +
                    '</a>' +

                    '<input type = "file"' +
                    'name = "ProductImage[]"' +
                    'class="file-input"' +
                    'accept = "image/*" ' +
                    'style = "display: none;" /> ' +
                    '</div > ' +
                    ' <input type="hidden" value="' + item.UploadedImage +'" name="ProdImageName[]" class="file-input" />'+

                    '<div class="error-msg productimage-error text-danger"' +
                    'style = "font-size: 12px;" > ' +
                    '</div>' +
                    '</td>';

                row += '<td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">' +
                    btnHtml +
                    '</td>';

                row += '</tr>';

                $('#tblRawMaterial tbody').append(row);
            });

            updateSerialNumbers();
        }

        function validateFileSize(input) {
            if (input.files && input.files[0]) {
                var fileSize = input.files[0].size;
                var maxSize = 50 * 1024 * 1024;
                if (fileSize > maxSize) {
                    alert("Please upload image below 50 MB only.");
                    input.value = "";
                    return false;
                }
            }
        }

        function GetSQFeet(val) {
            var row = $(val).closest("tr");

            var size = row.find(".size").val();
            var qty = parseFloat(row.find(".qty").val()) || 0;

            var sqftPerSheet = 0;

            if (size === "2x4") {
                sqftPerSheet = 2 * 4; // 8 sq ft
            } else if (size === "2x8") {
                sqftPerSheet = 2 * 8; // 16 sq ft
            } else if (size === "4x8") {
                sqftPerSheet = 4 * 8; // 32 sq ft
            }

            var totalSqFeet = sqftPerSheet * qty;

            row.find(".sqfeet").val(totalSqFeet);
        }

        $(document).on('click', '.upload-btn', function () {
            $(this).siblings('.file-input').click();
        });

        $(document).on('change', '.file-input', function () {

            const file = this.files[0];

            if (file) {
                const reader = new FileReader();
                const img = $(this).siblings('.product-image-preview');

                reader.onload = function (e) {
                    img.attr('src', e.target.result);
                };

                reader.readAsDataURL(file);
            }
        });
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Work Order</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btnDeList_Click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lbltallyref" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Tally Ref No:</asp:Label>
                            <asp:TextBox ID="txttallyref" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" ForeColor="Red" Font-Bold="true" OnTextChanged="txttallyref_TextChanged" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Enter Tally Ref. Number"
                                ControlToValidate="txttallyref" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblworkorderdate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Work Order Date:</asp:Label>
                            <asp:TextBox ID="txtworkorderdate" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Work Order Date"
                                ControlToValidate="txtworkorderdate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblDealerName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing Name:</asp:Label>
                            <asp:HiddenField ID="hdnDealerId" runat="server" />
                            <asp:TextBox ID="txtDealerName" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetDealerNameList"
                                TargetControlID="txtDealerName" OnClientItemSelected="DealerSelected">
                            </asp:AutoCompleteExtender>
                            <span class="highlight-checkbox">
                                <input type="checkbox" id="check_address" />
                                <label for="check_address">Create W/O Against Billing Name</label>
                            </span>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator18" runat="server" ErrorMessage="Please Enter Billing Name"
                                ControlToValidate="txtDealerName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>

                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblCustName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping Name:</asp:Label>
                            <asp:TextBox ID="txtCustName" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCustNameList"
                                TargetControlID="txtCustName" UseContextKey="true" OnClientItemSelected="CompanyData">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Shipping Name"
                                ControlToValidate="txtCustName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblcustRef" runat="server" Font-Bold="true" CssClass="form-label">Customer Ref.:</asp:Label>
                            <asp:TextBox ID="txtrefno" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblBillingAddress" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing Address:</asp:Label>
                            <asp:TextBox TextMode="MultiLine" ID="txtBillingAddress" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblShipAddress" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping Address:</asp:Label>
                            <div runat="server" id="divdropdown">
                                <asp:HiddenField ID="hdnShipAddressId" runat="server" />
                                <asp:DropDownList ID="ddlShipAddress" runat="server" CssClass="form-control" Style="height: 59px;" onchange="GetShippingDetails(this)">
                                    <asp:ListItem Value="">--Select Shipping Address --</asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Select Shipping Address"
                                    ControlToValidate="ddlShipAddress" ForeColor="Red" SetFocusOnError="true" InitialValue="" ValidationGroup="001"></asp:RequiredFieldValidator>
                            </div>
                            <div runat="server" id="divtxtbox" visible="false">
                                <asp:TextBox TextMode="MultiLine" ID="txtShipAddress" runat="server" ValidationGroup="001" CssClass="form-control" Style="height: 59px;"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" Enabled="false" runat="server" ErrorMessage="Please Select Shipping Address"
                                    ControlToValidate="txtShipAddress" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblBillGst" runat="server" Font-Bold="true" CssClass="form-label">Billing GstNo:</asp:Label>
                            <asp:TextBox ID="txtBillGst" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblShipGst" runat="server" Font-Bold="true" CssClass="form-label">Shipping GstNo:</asp:Label>
                            <asp:TextBox ID="txtShipGst" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <br />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 col-12" runat="server">
                            <asp:Label ID="lblBillPinCode" runat="server" Font-Bold="true" CssClass="form-label">Billing PinCode:</asp:Label>
                            <asp:TextBox ID="txtBillPinCode" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblShipPinCode" runat="server" Font-Bold="true" CssClass="form-label">Shipping PinCode:</asp:Label>
                            <asp:TextBox ID="txtShipPinCode" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <br />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblDeliveryDate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Delivery Date:</asp:Label>
                            <asp:TextBox ID="txtDeliveryDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ErrorMessage="Please Select Delivery Date"
                                ControlToValidate="txtDeliveryDate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12"></div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMCImage" runat="server" Font-Bold="true" CssClass="form-label">Attach Order <span class="text-danger mt-1">(.pdf)</span>:</asp:Label>
                            <asp:FileUpload ID="FileMCImage" runat="server" CssClass="form-control" accept=".pdf" onchange="validateFileSize(this)" />
                            <small class="text-danger d-block mt-1">Maximum file size: 50 MB</small>
                        </div>
                    </div>
                    <br />
                    <h5>Add Products</h5>
                    <hr />
                    <div class="table-responsive" style="overflow-x: auto;">
                        <table id="tblRawMaterial" style="max-width: 1400px; width: 100%; border-collapse: collapse; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.12); font-family: Segoe UI;">
                            <thead>
                                <tr style="background: #5b78b1; color: white; text-align: center; font-size: 15px; font-weight: 600; letter-spacing: 0.5px; height: 55px;">
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 50px;">Sr No</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 150px;">Product Name</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Item Code</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Type</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 200px;">Description</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Size</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 70px;">Qty</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 60px;">Sq Feet</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 60px;">Unit</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 100px;">Upload Image</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 80px;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr style="transition: 0.3s;">
                                    <!-- Sr No -->
                                    <td class="srno text-center"
                                        style="border: 1px solid #e3e6f0; padding: 10px; font-weight: 600; color: black !important;">1
                                    </td>

                                    <!-- Product Name -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text"
                                            name="ProductName[]"
                                            autocomplete="off"
                                            class="form-control productname"
                                            style="border-radius: 8px; height: 42px; min-width: 150px;" />
                                        <div class="error-msg productname-error text-danger" style="font-size: 12px;"></div>
                                        <input type="hidden" name="ProductId[]" class="productid" />
                                    </td>

                                    <!-- Sheet No -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text" name="SheetNo[]" autocomplete="off"
                                            class="form-control sheetno" rows="2"
                                            style="border-radius: 8px; min-width: 120px; resize: none;" />
                                        <div class="error-msg sheetno-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Type -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <select name="Type[]"
                                            class="form-control typo"
                                            style="border-radius: 8px; min-width: 120px; resize: none;">
                                            <option value="Regular" selected>Regular</option>
                                            <option value="Custom">Custom</option>
                                        </select>
                                        <div class="error-msg typo-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Description -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <textarea
                                            name="Description[]" autocomplete="off"
                                            class="form-control description"
                                            style="border-radius: 8px; height: 42px; min-width: 200px;"></textarea>
                                        <div class="error-msg descr-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Size -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <select name="Size[]"
                                            class="form-control size"
                                            style="border-radius: 8px; height: 42px; min-width: 120px;" onchange="GetSQFeet(this)">
                                            <option value="">-- Select Size --</option>
                                            <option value="2x4">2 x 4</option>
                                            <option value="2x8">2 x 8</option>
                                            <option value="4x8">4 x 8</option>
                                        </select>
                                        <div class="error-msg size-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Qty -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="number" step="0.01" name="Qty[]"
                                            class="form-control qty"
                                            style="border-radius: 8px; height: 42px; min-width: 70px;" oninput="GetSQFeet(this)" />
                                        <div class="error-msg qty-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Sq Feet -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text" name="SqFeet[]" readonly="readonly" class="form-control sqfeet"
                                            style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                        <div class="error-msg sqfeet-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Unit -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text" name="Unit[]" value="NOS" readonly="readonly" class="form-control unit"
                                            style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                        <div class="error-msg unit-error text-danger" style="font-size: 12px;"></div>
                                    </td>

                                    <!-- Upload Image -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <div class="position-relative d-inline-block">
                                            <img src="https://placehold.co/100x100?text=Image" class="product-image-preview"
                                            style="width: 70px; height: 70px; object-fit: cover; border: 1px solid #ddd; border-radius: 8px;" />
                                            <a href="javascript:void(0);" class="upload-btn position-absolute bottom-0 end-0 rounded-circle text-white border border-white shadow"
                                                style="background: rgb(89 118 175); width: 27px; height: 26px; display: flex; align-items: center; justify-content: center; font-size: 13px; cursor: pointer;">
                                                <i class="bi bi-camera"></i>
                                            </a>
                                            <input type="file" name="ProductImage[]" class="file-input" accept="image/*" style="display: none;" />
                                            <input type="hidden" name="ProdImageName[]" class="file-input" />
                                        </div>


                                        <div class="error-msg productimage-error text-danger"
                                            style="font-size: 12px;">
                                        </div>
                                    </td>

                                    <!-- Action -->
                                    <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <button type="button" class="btnAdd" style="border: none; background: none; cursor: pointer;">
                                            <i class="bi bi-plus-square-fill"
                                                style="color: #16a34a; font-size: 26px;"></i>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <hr />
                    <center>
                        <div>
                            <asp:HiddenField ID="hdnVal" runat="server" />
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btnsave_Click"></asp:LinkButton>
                        </div>
                    </center>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnsave" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

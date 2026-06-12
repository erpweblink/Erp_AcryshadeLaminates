<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="RawMaterialMaster.aspx.cs" Inherits="RawMaterialMaster" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style>
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
    </style>

    <script type="text/javascript">
        $(document).ready(function () {

            updateSerialNumbers();

            // ADD NEW ROW
            $(document).on('click', '.btnAdd', function () {

                var lastRow = $('#tblRawMaterial tbody tr:last');
                debugger;
                if (!validateRow(lastRow)) {
                    return;
                }

                var gstper = lastRow.find('.gstper').val() || '';

                // Convert current add button to delete
                $(this)
                    .removeClass('btnAdd')
                    .addClass('btnDelete')
                    .attr('style', 'border:none!important;background:none!important')
                    .html('<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>');

                // Create new row
                var newRow = `

                    <tr style="background-color:#ffffff;transition:0.3s;">

                        <td class="srno text-center"
                            style="border:1px solid #e3e6f0;
                            padding:10px;
                            font-weight:600;
                            color:black!important;">
                        </td>

                        <!-- Material Name -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <input type="text" autocomplete="off"
                                name="RawMaterialName[]"
                                class="form-control"
                                style="border-radius:8px;
                                height:42px;
                                min-width:200px;" />
                             <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>

                        <!-- Material Code -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <input type="text" autocomplete="off"
                                name="RawMaterialCode[]"
                                class="form-control"
                                style="border-radius:8px;
                                height:42px;
                                min-width:160px;" />
                            <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>

                        <!-- Category -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <select name="RawMaterialCategory[]"
                                class="form-control"
                                style="border-radius:8px;
                                height:42px;
                                min-width:200px;">

                                <option value="">-- Select Category --</option>
                                <option value="Chemical">Chemical</option>
                                <option value="Wood">Wood</option>
                                <option value="Adhesive">Adhesive</option>
                                <option value="Packaging">Packaging</option>
                                <option value="Additive">Additive</option>

                            </select>
                            <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>

                        <!-- Description -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <textarea name="RawMaterialDesc[]"
                                class="form-control"
                                rows="2"
                                style="border-radius:8px;
                                min-width:280px;
                                resize:none;"></textarea>
                            <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>

                        <!-- Qty -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <input type="number"
                                step="0.01"
                                name="RawMaterialQty[]"
                                class="form-control qty"
                                style="border-radius:8px;
                                height:42px;
                                min-width:120px;" />
                            <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>

                        <!-- Unit -->
                        <td style="border:1px solid #e3e6f0;padding:8px;">

                            <select name="Unit[]"
                                class="form-control"
                                style="border-radius:8px;
                                height:42px;
                                min-width:150px;">

                                <option value="">-- Select Unit --</option>
                                <option value="KGS">KGS</option>
                                <option value="LTRS">LTRS</option>
                                <option value="PCS">PCS</option>
                                <option value="TONS">TONS</option>
                                <option value="BAG">BAG</option>

                            </select>
                            <div class="error-msg text-danger" style="font-size:12px;"></div>
                        </td>


                        <!-- Action -->
                        <td class="text-center"
                            style="border:1px solid #e3e6f0;padding:8px;">

                            <button type="button"
                                class="btnAdd"
                                style="border:none;
                                background:none;
                                cursor:pointer;">

                                <i class="bi bi-plus-square-fill"
                                    style="color:#16a34a;
                                    font-size:26px;"></i>

                            </button>

                        </td>

                    </tr>

                `;

                $('#tblRawMaterial tbody').append(newRow);

                updateSerialNumbers();
            });

            // DELETE ROW
            $(document).on('click', '.btnDelete', function () {

                $(this).closest('tr').remove();

                updateSerialNumbers();
            });

        });

        // SERIAL NUMBER FUNCTION
        function updateSerialNumbers() {

            $('#tblRawMaterial tbody tr').each(function (index) {

                $(this).find('.srno').text(index + 1);

            });
        }


        function validateRow(row) {

            let isValid = true;

            // clear old errors
            row.find('.error-msg').text('');
            row.find('input,select,textarea').removeClass('error-border');

            let name = row.find('[name="RawMaterialName[]"]').val().trim();
            let code = row.find('[name="RawMaterialCode[]"]').val().trim();
            let category = row.find('[name="RawMaterialCategory[]"]').val();
            let desc = row.find('[name="RawMaterialDesc[]"]').val();
            let qty = row.find('.qty').val();
            let unit = row.find('[name="Unit[]"]').val();

            // Material Name
            if (name === '') {
                row.find('[name="RawMaterialName[]"]')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Material Name is required');
                isValid = false;
            }
            // Material Code
            if (code === '') {
                row.find('[name="RawMaterialCode[]"]')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Material Code is required');
                isValid = false;
            }

            // Category
            if (category === '') {
                row.find('[name="RawMaterialCategory[]"]')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Category is required');
                isValid = false;
            }
            // Material Desc
            if (desc === '') {
                row.find('[name="RawMaterialDesc[]"]')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Material Description is required');
                isValid = false;
            }

            // Qty
            if (qty === '' || parseFloat(qty) <= 0) {
                row.find('.qty')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Enter valid Qty');
                isValid = false;
            }

            // Unit
            if (unit === '') {
                row.find('[name="Unit[]"]')
                    .addClass('error-border')
                    .next('.error-msg')
                    .text('Unit is required');
                isValid = false;
            }

            return isValid;
        }

        function loadRawMaterialData(data) {
            $('#tblRawMaterial tbody').html('');

            $.each(data, function (index, item) {

                var btnHtml = '';

                if (index == data.length - 1) {
                    btnHtml =
                        '<button type="button" class="btnAdd"  style="border:none;background: none;cursor: pointer;">' +
                        '<i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>' +
                        '</button>';
                }
                else {
                    btnHtml =
                        '<button type="button" class="btnDelete" style="border:none!important;background:none!important">' +
                        '<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>' +
                        '</button>';
                }

                var row = '';

                row += '<tr style="background-color: #ffffff; transition: 0.3s;">';

                row += '<td class="srno text-center"  style="border:1px solid #e3e6f0;padding: 10px;font-weight: 600;color: black!important;">' + (index + 1) + '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">' +
                    '<input type="text" autocomplete="off" ' +
                    'name="RawMaterialName[]" ' +
                    'class="form-control" ' +
                    'value="' + item.RawMaterialName + '" ' +
                    'style="border-radius:8px;height:42px;min-width:200px;" />' +
                    '<div class="error-msg text-danger" style="font-size:12px;"></div>' +
                    '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">' +
                    '<input type="text" autocomplete="off" ' +
                    'name="RawMaterialCode[]" ' +
                    'class="form-control" ' +
                    'value="' + item.RawMaterialCode + '" ' +
                    'style="border-radius:8px;height:42px;min-width:160px;" />' +
                    '<div class="error-msg text-danger" style="font-size:12px;"></div>' +
                    '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">';
                row += '<select name="RawMaterialCategory[]" class="form-control" ' +
                    'style="border-radius:8px;height:42px;min-width:200px;">';

                row += '<option value="">-- Select Category --</option>';
                row += '<option value="Chemical"' + (item.RawMaterialCategory == 'Chemical' ? ' selected' : '') + '>Chemical</option>';
                row += '<option value="Wood"' + (item.RawMaterialCategory == 'Wood' ? ' selected' : '') + '>Wood</option>';
                row += '<option value="Adhesive"' + (item.RawMaterialCategory == 'Adhesive' ? ' selected' : '') + '>Adhesive</option>';
                row += '<option value="Packaging"' + (item.RawMaterialCategory == 'Packaging' ? ' selected' : '') + '>Packaging</option>';
                row += '<option value="Additive"' + (item.RawMaterialCategory == 'Additive' ? ' selected' : '') + '>Additive</option>';

                row += '</select>';
                row += '<div class="error-msg text-danger" style="font-size:12px;"></div>';
                row += '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">' +
                    '<textarea name="RawMaterialDesc[]" class="form-control" rows="2" ' +
                    'style="border-radius:8px;min-width:280px;resize:none;">' +
                    item.RawMaterialDesc +
                    '</textarea>' +
                    '<div class="error-msg text-danger" style="font-size:12px;"></div>' +
                    '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">' +
                    '<input type="number" step="0.01" ' +
                    'name="RawMaterialQty[]" ' +
                    'class="form-control qty" ' +
                    'value="' + item.RawMaterialQty + '" ' +
                    'style="border-radius:8px;height:42px;min-width:120px;" />' +
                    '<div class="error-msg text-danger" style="font-size:12px;"></div>' +
                    '</td>';

                row += '<td style="border:1px solid #e3e6f0;padding:8px;">';
                row += '<select name="Unit[]" class="form-control" ' +
                    'style="border-radius:8px;height:42px;min-width:150px;">';

                row += '<option value="">-- Select Unit --</option>';
                row += '<option value="KGS"' + (item.Unit == 'KGS' ? ' selected' : '') + '>KGS</option>';
                row += '<option value="LTRS"' + (item.Unit == 'LTRS' ? ' selected' : '') + '>LTRS</option>';
                row += '<option value="PCS"' + (item.Unit == 'PCS' ? ' selected' : '') + '>PCS</option>';
                row += '<option value="TONS"' + (item.Unit == 'TONS' ? ' selected' : '') + '>TONS</option>';
                row += '<option value="BAG"' + (item.Unit == 'BAG' ? ' selected' : '') + '>BAG</option>';

                row += '</select>';
                row += '<div class="error-msg text-danger" style="font-size:12px;"></div>';
                row += '</td>';

                row += '<td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">' +
                    btnHtml +
                    '</td>';

                row += '</tr>';

                $('#tblRawMaterial tbody').append(row);
            });

            updateSerialNumbers();
            $('#tblRawMaterial tbody tr').each(function () {
                calculateRow($(this));
            });
            calculateGrandTotal();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Raw Material</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_DeList_click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblSupplierName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Supplier Name:</asp:Label>
                            <asp:TextBox ID="txtSupplierName" Font-Bold="true" ForeColor="Red" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetSupplierNameList"
                                TargetControlID="txtSupplierName" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Supplier Name"
                                ControlToValidate="txtSupplierName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblPurchaseNo" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Purchase No:</asp:Label>
                            <asp:TextBox ID="txtPurchaseNo" runat="server" Font-Bold="true" ForeColor="Red" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetPurchaseNoList"
                                TargetControlID="txtPurchaseNo" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Purchase Number"
                                ControlToValidate="txtPurchaseNo" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblPurchaseDate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Purchase Date:</asp:Label>
                            <asp:TextBox ID="txtPurchaseDate" TextMode="Date" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Purchase Date"
                                ControlToValidate="txtPurchaseDate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />
                    <h5>Raw Materials Details</h5>
                    <hr />
                    <div class="table-responsive" style="overflow-x: auto;">
                        <table id="tblRawMaterial" style="min-width: 1800px; width: 100%; border-collapse: collapse; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.12); font-family: Segoe UI;">
                            <thead>
                                <tr style="background: #5b78b1; color: white; text-align: center; font-size: 15px; font-weight: 600; letter-spacing: 0.5px; height: 55px;">
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 80px;">Sr No</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Material Name</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Material Code</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Category</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 300px;">Description</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 140px;">Qty</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Unit</th>
                                    <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr style="background-color: #ffffff; transition: 0.3s;">
                                    <td class="srno text-center" style="border: 1px solid #e3e6f0; padding: 10px; font-weight: 600; color: black!important;">1 </td>
                                    <!-- Material Name -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text" name="RawMaterialName[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 200px;" />
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                    <!-- Material Code -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="text" name="RawMaterialCode[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 160px;" />
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                    <!-- Category -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <select name="RawMaterialCategory[]" class="form-control" style="border-radius: 8px; height: 42px; min-width: 200px;">
                                            <option value="">-- Select Category --</option>
                                            <option value="Chemical">Chemical</option>
                                            <option value="Wood">Wood</option>
                                            <option value="Adhesive">Adhesive</option>
                                            <option value="Packaging">Packaging</option>
                                            <option value="Additive">Additive</option>
                                        </select>
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                    <!-- Description -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <textarea name="RawMaterialDesc[]" class="form-control" rows="2" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                    <!-- Qty -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <input type="number" step="0.01" name="RawMaterialQty[]" class="form-control qty" style="border-radius: 8px; height: 42px; min-width: 120px;" />
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                    <!-- Unit -->
                                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <select name="Unit[]" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;">
                                            <option value="">-- Select Unit --</option>
                                            <option value="KGS">KGS</option>
                                            <option value="LTRS">LTRS</option>
                                            <option value="PCS">PCS</option>
                                            <option value="TONS">TONS</option>
                                            <option value="BAG">BAG</option>
                                        </select>
                                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                    </td>
                                  
                                    <!-- Action -->
                                    <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                                        <button type="button" class="btnAdd" style="border: none; background: none; cursor: pointer;"><i class="bi bi-plus-square-fill" style="color: #16a34a; font-size: 26px;"></i></button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <hr />
                    <center>
                        <div>
                            <asp:HiddenField ID="hdnVal" runat="server" />
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
                        </div>
                    </center>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

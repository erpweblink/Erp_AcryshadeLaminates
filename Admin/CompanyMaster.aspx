<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="CompanyMaster.aspx.cs" Inherits="CompanyMaster" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
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
    </style>

    <script type="text/javascript">

        // BILLING ADDRESS ADD
        $(document).on('click', '#billTable .btnAdd', function () {

            if (!validateBillingRows()) {
                return;
            }

            $(this)
                .removeClass('btnAdd')
                .addClass('btnDelete')
                .attr('style', 'border:none!important;background:none!important')
                .html('<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>');

            var row = `
                <tr style="transition:0.3s;">

                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="GSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="PinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                        <input type="text" name="Country[]" class="form-control country" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                        <input type="text" name="State[]" class="form-control state" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                        <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="City[]" class="form-control city" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                   <td style="border: 1px solid #e3e6f0; padding: 8px;">
                        <textarea type="text" name="Address[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                   </td>

                    <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="Area[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                    </td>

                    <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                        <button type="button" class="btnAdd" style="border:none;background:none;">
                            <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>
                        </button>
                    </td>

                </tr>`;

            $('#billTable tbody').append(row);
        });

        $(document).on('click', '#billTable .btnDelete', function () {

            $(this).closest('tr').remove();

            if ($('#check_address').is(':checked')) {
                $('#check_address').trigger('change');
            }
        });

        // SHIPPING ADDRESS ADD
        $(document).on('click', '#shipTable .btnAdd', function () {

            if (!validateShippingRows()) {
                return;
            }

            $(this)
                .removeClass('btnAdd')
                .addClass('btnDelete')
                .attr('style', 'border:none!important;background:none!important')
                .html('<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>');

            var row = `
                <tr style="transition:0.3s;">


                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SGSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SPinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SCountry[]" class="form-control scountry" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SState[]" class="form-control sstate" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SCity[]" class="form-control scity" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <textarea type="text" name="SAddress[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SArea[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                    <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                        <button type="button" class="btnAdd" style="border:none;background:none;">
                            <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>
                        </button>
                    </td>

                </tr>`;

            $('#shipTable tbody').append(row);
            loadCountries();
        });

        $(document).on('click', '#shipTable .btnDelete', function () {

            $(this).closest('tr').remove();
        });

        //Data by billing Postal Code
        $(document).on('blur', '[name="PinCode[]"]', function () {

            let pincode = $(this).val();
            let row = $(this).closest('tr');

            if (pincode.length !== 6) {
                return;
            }

            fetch('https://api.postalpincode.in/pincode/' + pincode)
                .then(response => response.json())
                .then(data => {

                    if (
                        data[0].Status === "Success" &&
                        data[0].PostOffice &&
                        data[0].PostOffice.length > 0
                    ) {

                        var areas = data[0].PostOffice.map(x => x.Name).join(', ');

                        row.find('[name="Country[]"]').val(data[0].PostOffice[0].Country);
                        row.find('[name="State[]"]').val(data[0].PostOffice[0].State);
                        row.find('[name="City[]"]').val(data[0].PostOffice[0].District);
                        row.find('[name="Area[]"]').val(areas);

                    } else {
                        alert('Invalid PIN Code');
                    }
                })
                .catch(error => {
                    console.error(error);
                    alert('Unable to fetch PIN details.');
                });

        });

        //Data by shipping Postal Code
        $(document).on('blur', '[name="SPinCode[]"]', function () {

            let pincode = $(this).val();
            let row = $(this).closest('tr');

            if (pincode.length !== 6)
                return;

            fetch('https://api.postalpincode.in/pincode/' + pincode)
                .then(response => response.json())
                .then(data => {

                    if (
                        data[0].Status === "Success" &&
                        data[0].PostOffice &&
                        data[0].PostOffice.length > 0
                    ) {

                        var areas = data[0].PostOffice.map(x => x.Name).join(', ');

                        row.find('[name="SCountry[]"]').val(data[0].PostOffice[0].Country);
                        row.find('[name="SState[]"]').val(data[0].PostOffice[0].State);
                        row.find('[name="SCity[]"]').val(data[0].PostOffice[0].District);
                        row.find('[name="SArea[]"]').val(areas);

                    } else {
                        alert('Invalid PIN Code');
                    }
                })
                .catch(error => {
                    console.error(error);
                    alert('Unable to fetch PIN details.');
                });
        });

        // CONTACT DETAILS ADD
        $(document).on('click', '#CntTable .btnAdd', function () {

            if (!validateContactRows()) {
                return;
            }

            $(this)
                .removeClass('btnAdd')
                .addClass('btnDelete')
                .html('<i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>');

            var row = `

                <tr style="transition:0.3s;">

                    <td style="border:1px solid #e3e6f0;padding:8px;">
                        <input type="text" name="Cname[]" autocomplete="off" class="form-control"
                            style="border-radius:8px;height:42px;min-width:150px;" />
                        <div class="error-msg text-danger"></div>
                    </td>

                    <td style="border:1px solid #e3e6f0;padding:8px;">
                        <input type="text" name="CmobNo[]" autocomplete="off" class="form-control"
                            style="border-radius:8px;height:42px;min-width:180px;" />
                        <div class="error-msg text-danger"></div>
                    </td>

                    <td style="border:1px solid #e3e6f0;padding:8px;">
                        <input type="text" name="CemialId[]" autocomplete="off" class="form-control"
                            style="border-radius:8px;height:42px;min-width:220px;" />
                        <div class="error-msg text-danger"></div>
                    </td>

                    <td style="border:1px solid #e3e6f0;padding:8px;">
                        <input type="text" name="Cdept[]" autocomplete="off" class="form-control"
                            style="border-radius:8px;height:42px;min-width:180px;" />
                        <div class="error-msg text-danger"></div>
                    </td>

                    <td style="border:1px solid #e3e6f0;padding:8px;">
                        <input type="text" name="Cdesig[]" autocomplete="off" class="form-control"
                            style="border-radius:8px;height:42px;min-width:180px;" />
                        <div class="error-msg text-danger"></div>
                    </td>

                    <td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">
                        <button type="button" class="btnAdd"
                            style="border:none;background:none;cursor:pointer;">
                            <i class="bi bi-plus-square-fill"
                               style="color:#16a34a;font-size:26px;"></i>
                        </button>
                    </td>

                </tr>`;

            $('#CntTable tbody').append(row);
        });

        $(document).on('click', '#CntTable .btnDelete', function () {

            $(this).closest('tr').remove();

        });

        function validateBillingRows() {
            let isValid = true;
            $('#billTable tbody tr').each(function () {

                let row = $(this);

                row.find('.error-msg').text('');
                row.find('input,textarea').removeClass('error-border');

                function showError(selector, msg) {

                    row.find(selector)
                        .addClass('error-border')
                        .next('.error-msg')
                        .text(msg);

                    isValid = false;
                }

                if (row.find('[name="Address[]"]').val().trim() === '')
                    showError('[name="Address[]"]', 'Address is required');

                let pincode = row.find('[name="PinCode[]"]').val().trim();

                if (pincode === '')
                    showError('[name="PinCode[]"]', 'Pincode is required');
                else if (!/^[0-9]{6}$/.test(pincode))
                    showError('[name="PinCode[]"]', 'Enter valid 6 digit Pincode');
            });

            return isValid;
        }

        function validateShippingRows() {

            let isValid = true;

            $('#shipTable tbody tr').each(function () {

                let row = $(this);

                row.find('.error-msg').text('');
                row.find('input,textarea').removeClass('error-border');

                function showError(selector, msg) {

                    row.find(selector)
                        .addClass('error-border')
                        .next('.error-msg')
                        .text(msg);

                    isValid = false;
                }

                if (row.find('[name="SAddress[]"]').val().trim() === '')
                    showError('[name="SAddress[]"]', 'Address is required');

                let pincode = row.find('[name="SPinCode[]"]').val().trim();

                if (pincode === '')
                    showError('[name="SPinCode[]"]', 'Pincode is required');
                else if (!/^[0-9]{6}$/.test(pincode))
                    showError('[name="SPinCode[]"]', 'Enter valid 6 digit Pincode');
            });

            return isValid;
        }

        function validateContactRows() {

            let isValid = true;

            $('#CntTable tbody tr').each(function () {

                let row = $(this);

                row.find('.error-msg').text('');
                row.find('input').removeClass('error-border');

                function showError(selector, msg) {

                    row.find(selector)
                        .addClass('error-border')
                        .next('.error-msg')
                        .text(msg);

                    isValid = false;
                }

                let name = row.find('[name="Cname[]"]').val().trim();
                let mobile = row.find('[name="CmobNo[]"]').val().trim();
                let email = row.find('[name="CemialId[]"]').val().trim();
                let dept = row.find('[name="Cdept[]"]').val().trim();
                let desig = row.find('[name="Cdesig[]"]').val().trim();

                //if (name === '')
                //    showError('[name="Cname[]"]', 'Name is required');

                //if (mobile === '')
                //    showError('[name="CmobNo[]"]', 'Mobile No is required');
                //else if (!/^[0-9]{10}$/.test(mobile))
                //    showError('[name="CmobNo[]"]', 'Enter valid 10 digit Mobile No');

                //if (email === '')
                //    showError('[name="CemialId[]"]', 'Email Id is required');
                //else if (!/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email))
                //    showError('[name="CemialId[]"]', 'Enter valid Email Id');

                //if (dept === '')
                //    showError('[name="Cdept[]"]', 'Department is required');

                //if (desig === '')
                //    showError('[name="Cdesig[]"]', 'Designation is required');
            });

            return isValid;
        }

        $(document).on(
            'keyup change',
            '#billTable input,#billTable textarea',
            function () {

                if ($('#check_address').is(':checked')) {
                    $('#check_address').trigger('change');
                }
            }
        );

        // Copy Billing Address To Shipping Address
        $(document).on('change', '#check_address', function () {

            if ($(this).is(':checked')) {

                $('#shipTable tbody').html('');

                $('#billTable tbody tr').each(function (index) {

                    var billRow = $(this);
                    var totalRows = $('#billTable tbody tr').length;
                    var isLastRow = (index === totalRows - 1);

                    var actionButton = isLastRow
                        ? `<button type="button" class="btnAdd" style="border:none;background:none;">
                                <i class="bi bi-plus-square-fill"
                                   style="color:#16a34a;font-size:26px"></i>
                           </button>`
                        : `<button type="button" class="btnDelete" style="border:none!important;background:none!important">
                                <i class="bi bi-trash-fill" style="color:red;font-size:23px"></i>
                           </button>`;


                    var newRow = `
                    <tr style="transition:0.3s;">

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SGSTNo[]" class="form-control"
                                value="${billRow.find('[name="GSTNo[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SPinCode[]" class="form-control"
                                value="${billRow.find('[name="PinCode[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SCountry[]" class="form-control"
                                value="${billRow.find('[name="Country[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SState[]" class="form-control"
                                value="${billRow.find('[name="State[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SCity[]" class="form-control"
                                value="${billRow.find('[name="City[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <textarea name="SAddress[]" class="form-control">${billRow.find('[name="Address[]"]').val()}</textarea>
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td style="border:1px solid #e3e6f0;padding:8px;">
                            <input type="text" name="SArea[]" class="form-control"
                                value="${billRow.find('[name="Area[]"]').val()}" />
                            <div class="error-msg text-danger"></div>
                        </td>

                        <td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">
                              ${actionButton}
                        </td>

                    </tr>`;

                    $('#shipTable tbody').append(newRow);
                });
            }
            else {
                // Uncheck => clear shipping table and add blank row
                $('#shipTable tbody').html(`
                <tr style="transition:0.3s;">
                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SGSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SPinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SCountry[]" class="form-control scountry" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SState[]" class="form-control sstate" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SCity[]" class="form-control scity" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <textarea type="text" name="SAddress[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                            <input type="text" name="SArea[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                            <button type="button" class="btnAdd" style="border:none;background:none;">
                                <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>
                            </button>
                        </td>

                    </tr>`);
            }
        });

        // Validation On KeyPress
        // ==========================
        // GST NUMBER
        // ==========================
        $(document).on('input', '[name="GSTNo[]"], [name="SGSTNo[]"]', function () {

            let value = $(this).val().toUpperCase();

            // Allow only GST valid chars
            value = value.replace(/[^A-Z0-9]/g, '');

            // Max length 15
            if (value.length > 15)
                value = value.substring(0, 15);

            $(this).val(value);
        });

        // ==========================
        // PINCODE
        // ==========================
        $(document).on('input', '[name="PinCode[]"], [name="SPinCode[]"]', function () {

            let value = $(this).val().replace(/\D/g, '');

            if (value.length > 6)
                value = value.substring(0, 6);

            $(this).val(value);
        });

        // ==========================
        // MOBILE NUMBER
        // ==========================
        $(document).on('input', '[name="CmobNo[]"]', function () {

            let value = $(this).val().replace(/\D/g, '');

            if (value.length > 10)
                value = value.substring(0, 10);

            $(this).val(value);
        });

        // ==========================
        // NAME
        // ==========================
        $(document).on('input', '[name="Cname[]"]', function () {

            let value = $(this).val();

            value = value.replace(/[^a-zA-Z\s]/g, '');

            $(this).val(value);
        });

        // ==========================
        // CITY
        // ==========================
        $(document).on('input',
            '[name="City[]"], [name="SCity[]"]',
            function () {

                let value = $(this).val();

                value = value.replace(/[^a-zA-Z\s]/g, '');

                $(this).val(value);
            });

        // ==========================
        // STATE
        // ==========================
        $(document).on('input',
            '[name="State[]"], [name="SState[]"]',
            function () {

                let value = $(this).val();

                value = value.replace(/[^a-zA-Z\s]/g, '');

                $(this).val(value);
            });

        // ==========================
        // COUNTRY
        // ==========================
        $(document).on('input',
            '[name="Country[]"], [name="SCountry[]"]',
            function () {

                let value = $(this).val();

                value = value.replace(/[^a-zA-Z\s]/g, '');

                $(this).val(value);
            });

        // ==========================
        // DEPARTMENT
        // ==========================
        $(document).on('input', '[name="Cdept[]"]', function () {

            let value = $(this).val();

            value = value.replace(/[^a-zA-Z\s]/g, '');

            $(this).val(value);
        });

        // ==========================
        // DESIGNATION
        // ==========================
        $(document).on('input', '[name="Cdesig[]"]', function () {

            let value = $(this).val();

            value = value.replace(/[^a-zA-Z\s]/g, '');

            $(this).val(value);
        });


        // Below function are used to load the company master 
        function loadCompanyData(data) {
            loadBillingData(data.Addresses);
            loadShippingData(data.Addresses);
            loadContactData(data.Contacts);
        }

        function loadBillingData(addresses) {
            $('#billTable tbody').html('');

            var validAddresses = addresses.filter(function (item) {
                return (
                    (item.BillGSTNo || '').trim() !== '' ||
                    (item.BillPinCode || '').trim() !== '' ||
                    (item.BillCountry || '').trim() !== '' ||
                    (item.BillState || '').trim() !== '' ||
                    (item.BillCity || '').trim() !== '' ||
                    (item.BillAddress || '').trim() !== '' ||
                    (item.BillArea || '').trim() !== ''
                );
            });
            if (validAddresses.length > 0) {
                $.each(addresses, function (i, item) {

                    var isEmpty =
                        !item.BillPinCode &&
                        !item.BillAddress;

                    if (isEmpty) {
                        return true; // continue to next item
                    }

                    var btnHtml =
                        i === addresses.length - 1
                            ? '<button type="button" class="btnAdd" style="border:none;background:none;"><i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i></button>'
                            : '<button type="button" class="btnDelete" style="border:none;background:none;"><i class="bi bi-trash-fill" style="color:red;font-size:23px"></i></button>';

                    var row = `
                 <tr style="transition:0.3s;">

                         <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="GSTNo[]" autocomplete="off" class="form-control" value="${item.BillGSTNo || ''}" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="PinCode[]" autocomplete="off" class="form-control" value="${item.BillPinCode || ''}" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <input type="text"  name="Country[]" value="${item.BillCountry || ''}" class="form-control country" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                             <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <input type="text"  name="State[]" value="${item.BillState || ''}" class="form-control state" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                             <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text"  name="City[]" value="${item.BillCity || ''}" class="form-control city" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <textarea type="text" name="Address[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;">${item.BillAddress || ''}</textarea>
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                         <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="Area[]" autocomplete="off" class="form-control"  value="${item.BillArea || ''}" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                         </td>

                         <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                            ${btnHtml}
                         </td>
                </tr>`;

                    $('#billTable tbody').append(row);

                })
            } else {
                $('#billTable tbody').html(`
                     <tr style="transition:0.3s;">

                         <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="GSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="PinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <input type="text" name="Country[]" class="form-control country" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                             <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <input type="text" name="State[]" class="form-control state" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                             <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="City[]" class="form-control city" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                             <textarea type="text" name="Address[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                        </td>

                         <td style="border: 1px solid #e3e6f0; padding: 8px;">
                              <input type="text" name="Area[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                              <div class="error-msg text-danger" style="font-size: 12px;"></div>
                         </td>

                         <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                             <button type="button" class="btnAdd" style="border:none;background:none;">
                                 <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>
                             </button>
                         </td>

                     </tr>`);
            }
        }

        function loadShippingData(addresses) {
            $('#shipTable tbody').html('');

            var validAddresses = addresses.filter(function (item) {
                return (
                    (item.ShipGSTNo || '').trim() !== '' ||
                    (item.ShipPinCode || '').trim() !== '' ||
                    (item.ShipCountry || '').trim() !== '' ||
                    (item.ShipState || '').trim() !== '' ||
                    (item.ShipCity || '').trim() !== '' ||
                    (item.ShipAddress || '').trim() !== '' ||
                    (item.ShipArea || '').trim() !== ''
                );
            });
            if (validAddresses.length > 0) {
                $.each(addresses, function (i, item) {

                    var isEmpty =
                        !item.ShipPinCode &&
                        !item.ShipAddress;

                    if (isEmpty) {
                        return true; // continue to next item
                    }


                    var btnHtml =
                        i === addresses.length - 1
                            ? '<button type="button" class="btnAdd" style="border:none;background:none;"><i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i></button>'
                            : '<button type="button" class="btnDelete" style="border:none;background:none;"><i class="bi bi-trash-fill" style="color:red;font-size:23px"></i></button>';

                    var row = `

                 <tr style="transition:0.3s;">

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SGSTNo[]" class="form-control"
                         value="${item.ShipGSTNo || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SPinCode[]" class="form-control"
                         value="${item.ShipPinCode || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SCountry[]" class="form-control"
                         value="${item.ShipCountry || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SState[]" class="form-control"
                         value="${item.ShipState || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SCity[]" class="form-control"
                         value="${item.ShipCity || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <textarea name="SAddress[]" class="form-control">${item.ShipAddress || ''}</textarea>
                     <div class="error-msg text-danger"></div>
                 </td>

                 <td style="border:1px solid #e3e6f0;padding:8px;">
                     <input type="text" name="SArea[]" class="form-control"
                         value="${item.ShipArea || ''}" />
                     <div class="error-msg text-danger"></div>
                 </td>

             <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">${btnHtml}</td>
        </tr>`;

                    $('#shipTable tbody').append(row);

                })
            } else {
                $('#shipTable tbody').html(`
                  <tr style="transition:0.3s;">
                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SGSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SPinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SCountry[]" class="form-control scountry" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SState[]" class="form-control sstate" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SCity[]" class="form-control scity" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <textarea type="text" name="SAddress[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td style="border: 1px solid #e3e6f0; padding: 8px;">
                         <input type="text" name="SArea[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                         <div class="error-msg text-danger" style="font-size: 12px;"></div>
                     </td>

                     <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
                         <button type="button" class="btnAdd" style="border:none;background:none;">
                             <i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i>
                         </button>
                     </td>

                 </tr>`);
            }
        }

        function loadContactData(contacts) {
            $('#CntTable tbody').html('');

            var validContacts = contacts.filter(function (item) {
                return (
                    (item.FName || '').trim() !== '' ||
                    (item.MobileNo || '').trim() !== '' ||
                    (item.EmialID || '').trim() !== '' ||
                    (item.Department || '').trim() !== '' ||
                    (item.Designation || '').trim() !== ''
                );
            });

            if (validContacts.length > 0) {
                $.each(contacts, function (i, item) {

                    var btnHtml =
                        i === contacts.length - 1
                            ? '<button type="button" class="btnAdd" style="border:none;background:none;"><i class="bi bi-plus-square-fill" style="color:#16a34a;font-size:26px"></i></button>'
                            : '<button type="button" class="btnDelete" style="border:none;background:none;"><i class="bi bi-trash-fill" style="color:red;font-size:23px"></i></button>';

                    var row = `

                 <tr style="transition: 0.3s;">

                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="Cname[]" autocomplete="off" value="${item.FName || ''}" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                     <div class="error-msg text-danger" style="font-size: 12px;"></div>
                 </td>

                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="CmobNo[]" autocomplete="off" value="${item.MobileNo || ''}" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;" />
                     <div class="error-msg text-danger" style="font-size: 12px;"></div>
                 </td>

                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="CemialId[]" autocomplete="off" value="${item.EmialID || ''}" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                     <div class="error-msg text-danger" style="font-size: 12px;"></div>
                 </td>

                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="Cdept[]" autocomplete="off" value="${item.Department || ''}" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                     <div class="error-msg text-danger" style="font-size: 12px;"></div>
                 </td>

                 <td style="border: 1px solid #e3e6f0; padding: 8px;">
                     <input type="text" name="Cdesig[]" autocomplete="off" value="${item.Designation || ''}" class="form-control qty" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                     <div class="error-msg text-danger" style="font-size: 12px;"></div>
                 </td>

                 <!-- Action -->
                 <td class="text-center" style="border: 1px solid #e3e6f0; padding: 8px;">
               ${btnHtml}</td>
        </tr>`;

                    $('#CntTable tbody').append(row);
                })
            } else {
                $('#CntTable tbody').html(`
                  <tr style="transition:0.3s;">

                     <td style="border:1px solid #e3e6f0;padding:8px;">
                         <input type="text" name="Cname[]" autocomplete="off" class="form-control"
                             style="border-radius:8px;height:42px;min-width:150px;" />
                         <div class="error-msg text-danger"></div>
                     </td>

                     <td style="border:1px solid #e3e6f0;padding:8px;">
                         <input type="text" name="CmobNo[]" autocomplete="off" class="form-control"
                             style="border-radius:8px;height:42px;min-width:180px;" />
                         <div class="error-msg text-danger"></div>
                     </td>

                     <td style="border:1px solid #e3e6f0;padding:8px;">
                         <input type="text" name="CemialId[]" autocomplete="off" class="form-control"
                             style="border-radius:8px;height:42px;min-width:220px;" />
                         <div class="error-msg text-danger"></div>
                     </td>

                     <td style="border:1px solid #e3e6f0;padding:8px;">
                         <input type="text" name="Cdept[]" autocomplete="off" class="form-control"
                             style="border-radius:8px;height:42px;min-width:180px;" />
                         <div class="error-msg text-danger"></div>
                     </td>

                     <td style="border:1px solid #e3e6f0;padding:8px;">
                         <input type="text" name="Cdesig[]" autocomplete="off" class="form-control"
                             style="border-radius:8px;height:42px;min-width:180px;" />
                         <div class="error-msg text-danger"></div>
                     </td>

                     <td class="text-center" style="border:1px solid #e3e6f0;padding:8px;">
                         <button type="button" class="btnAdd"
                             style="border:none;background:none;cursor:pointer;">
                             <i class="bi bi-plus-square-fill"
                                style="color:#16a34a;font-size:26px;"></i>
                         </button>
                     </td>

                 </tr>`);
            }

        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card">
                    <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                        <h3 class="m-0 font-weight-bold"><b>Sub Dealers</b></h3>
                        <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_DeList_click" />
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6 col-12">
                                <asp:Label ID="lblCompanyName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Company Name:</asp:Label>
                                <asp:TextBox ID="txtCompanyName" Font-Bold="true" ForeColor="Red" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                                <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                    CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                    CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCompanyNameList"
                                    TargetControlID="txtCompanyName" Enabled="true">
                                </asp:AutoCompleteExtender>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Company Name"
                                    ControlToValidate="txtCompanyName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                            </div>
                            <div class="col-md-6 col-12">
                                <asp:Label ID="lblOwnerName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Client Name:</asp:Label>
                                <asp:TextBox ID="txtOwnerName" runat="server" Font-Bold="true" ForeColor="Red" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Client Name"
                                    ControlToValidate="txtOwnerName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblCompanyOrigin" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Company Origin:</asp:Label>
                                <asp:DropDownList ID="ddlCompanyOrigin" runat="server" Enabled="false" CssClass="form-control" Font-Bold="true" ForeColor="Green">
                                    <asp:ListItem Value="">--Select Origin--</asp:ListItem>
                                    <asp:ListItem Value="Domestic" Selected="True">Indian Company</asp:ListItem>
                                    <asp:ListItem Value="Foreign">Foreign Company</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblCompanyEmialId" runat="server" Font-Bold="true" CssClass="form-label">Emial Id:</asp:Label>
                                <asp:TextBox ID="txtCompanyEmialId" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblPanCard" runat="server" Font-Bold="true" CssClass="form-label">Pan Card No:</asp:Label>
                                <asp:TextBox ID="txtCompanyPanCard" Font-Bold="true" ForeColor="Red" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Client Name"
                                    ControlToValidate="txtCompanyPanCard" ForeColor="Red" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblPaymentTerms" runat="server" Font-Bold="true" CssClass="form-label">Payment Terms:</asp:Label>
                                <asp:TextBox ID="txtPaymentTerms" runat="server" Font-Bold="true" ForeColor="Red" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblUDYAMNo" runat="server" Font-Bold="true" CssClass="form-label">UDYAM No:</asp:Label>
                                <asp:TextBox ID="txtUDYAMNo" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-4 col-12">
                                <asp:Label ID="lblWebsiteLink" runat="server" Font-Bold="true" CssClass="form-label">Website Link:</asp:Label>
                                <asp:TextBox ID="txtWebsiteLink" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <br />
                        <br />
                        <h5>Billing Address</h5>
                        <hr />
                        <div class="table-responsive" style="overflow-x: auto;">
                            <table id="billTable" style="border-collapse: collapse; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.12); font-family: Segoe UI;">
                                <thead>
                                    <tr style="background: #5b78b1; color: white; text-align: center; font-size: 15px; font-weight: 600; letter-spacing: 0.5px; height: 55px;">
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">GST No</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">PinCode</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Country</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">State</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">City</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Address</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Area</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr style="transition: 0.3s;">

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="GSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="PinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="Country[]" class="form-control country" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="State[]" class="form-control state" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="City[]" class="form-control city" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <textarea type="text" name="Address[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="Area[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
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
                        <br />
                        <br />
                        <h5>Shipping Address</h5>
                        <span>
                            <input type="checkbox" id="check_address" />
                            <label for="check_address">Copy Billing Details</label>
                        </span>
                        <hr />
                        <div class="table-responsive" style="overflow-x: auto;">
                            <table id="shipTable" style="border-collapse: collapse; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.12); font-family: Segoe UI;">
                                <thead>
                                    <tr style="background: #5b78b1; color: white; text-align: center; font-size: 15px; font-weight: 600; letter-spacing: 0.5px; height: 55px;">
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">GST No</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">PinCode</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Country</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">State</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">City</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Address</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Area</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr style="transition: 0.3s;">

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SGSTNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SPinCode[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SCountry[]" class="form-control scountry" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SState[]" class="form-control sstate" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SCity[]" class="form-control scity" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <textarea type="text" name="SAddress[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;"></textarea>
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="SArea[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
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
                        <br />
                        <br />
                        <h5>Contact Details</h5>
                        <hr />
                        <div class="table-responsive" style="overflow-x: auto;">
                            <table id="CntTable" style="border-collapse: collapse; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.12); font-family: Segoe UI;">
                                <thead>
                                    <tr style="background: #5b78b1; color: white; text-align: center; font-size: 15px; font-weight: 600; letter-spacing: 0.5px; height: 55px;">
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Name</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Mobile No</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 220px;">Email Id</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Department</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 180px;">Designation</th>
                                        <th style="border: 1px solid #dcdcdc; padding: 12px; min-width: 120px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr style="transition: 0.3s;">

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="Cname[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 150px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="CmobNo[]" autocomplete="off" class="form-control" style="border-radius: 8px; min-width: 280px; resize: none;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="CemialId[]" autocomplete="off" class="form-control" style="border-radius: 8px; height: 42px; min-width: 180px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="Cdept[]" autocomplete="off" class="form-control" rows="2" style="border-radius: 8px; height: 42px; min-width: 60px;" />
                                            <div class="error-msg text-danger" style="font-size: 12px;"></div>
                                        </td>

                                        <td style="border: 1px solid #e3e6f0; padding: 8px;">
                                            <input type="text" name="Cdesig[]" autocomplete="off" class="form-control qty" style="border-radius: 8px; height: 42px; min-width: 60px;" />
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
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

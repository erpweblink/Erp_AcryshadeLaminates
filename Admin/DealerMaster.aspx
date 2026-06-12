<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="DealerMaster.aspx.cs" Inherits="DealerMaster" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
        .spncls {
            color: red;
        }
    </style>
    <script type="text/javascript">
        function bindPinInfo(ctrl) {

            var pincode = ctrl.value.trim();

            if (pincode.length !== 6) {
                return;
            }

            fetch('https://api.postalpincode.in/pincode/' + pincode)
                .then(response => response.json())
                .then(data => {

                    if (data[0].Status === "Success" &&
                        data[0].PostOffice &&
                        data[0].PostOffice.length > 0) {

                        var areas = data[0].PostOffice.map(x => x.Name).join(', ');

                        document.getElementById('<%= txtBillArea.ClientID %>').value = areas;
                        document.getElementById('<%= txtBillCity.ClientID %>').value = data[0].PostOffice[0].District;
                        document.getElementById('<%= txtBillState.ClientID %>').value = data[0].PostOffice[0].State;
                        document.getElementById('<%= txtBillCountry.ClientID %>').value = data[0].PostOffice[0].Country;


                       <%-- var po = data[0].PostOffice[0];

                        document.getElementById('<%= txtBillArea.ClientID %>').value =
                            po.Name || '';

                        document.getElementById('<%= txtBillCity.ClientID %>').value =
                            po.District || '';

                        document.getElementById('<%= txtBillState.ClientID %>').value =
                            po.State || '';

                        document.getElementById('<%= txtBillCountry.ClientID %>').value =
                            po.Country || '';--%>
                    }
                    else {

                        document.getElementById('<%= txtBillArea.ClientID %>').value = '';
                        document.getElementById('<%= txtBillCity.ClientID %>').value = '';
                        document.getElementById('<%= txtBillState.ClientID %>').value = '';
                        document.getElementById('<%= txtBillCountry.ClientID %>').value = '';

                        alert('Invalid PIN Code');
                    }
                })
                .catch(error => {
                    console.log(error);
                    alert('Unable to fetch PIN details.');
                });
        }

        function bindSPinInfo(ctrl) {

            var pincode = ctrl.value.trim();

            if (pincode.length !== 6) {
                return;
            }

            fetch('https://api.postalpincode.in/pincode/' + pincode)
                .then(response => response.json())
                .then(data => {

                    if (data[0].Status === "Success" &&
                        data[0].PostOffice &&
                        data[0].PostOffice.length > 0) {

                        var areas = data[0].PostOffice.map(x => x.Name).join(', ');

                        document.getElementById('<%= txtShipArea.ClientID %>').value = areas;
                        document.getElementById('<%= txtShipCity.ClientID %>').value = data[0].PostOffice[0].District;
                        document.getElementById('<%= txtShipState.ClientID %>').value = data[0].PostOffice[0].State;
                        document.getElementById('<%= txtShipCountry.ClientID %>').value = data[0].PostOffice[0].Country;


                       <%-- var po = data[0].PostOffice[0];

                        document.getElementById('<%= txtBillArea.ClientID %>').value =
                            po.Name || '';

                        document.getElementById('<%= txtBillCity.ClientID %>').value =
                            po.District || '';

                        document.getElementById('<%= txtBillState.ClientID %>').value =
                            po.State || '';

                        document.getElementById('<%= txtBillCountry.ClientID %>').value =
                            po.Country || '';--%>
                    }
                    else {

                        document.getElementById('<%= txtShipArea.ClientID %>').value = '';
                        document.getElementById('<%= txtShipCity.ClientID %>').value = '';
                        document.getElementById('<%= txtShipState.ClientID %>').value = '';
                        document.getElementById('<%= txtShipCountry.ClientID %>').value = '';

                        alert('Invalid PIN Code');
                    }
                })
                .catch(error => {
                    console.log(error);
                    alert('Unable to fetch PIN details.');
                });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Dealer</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_DeList_click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserType" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Type :</asp:Label>
                            <asp:DropDownList ID="ddlUserType" Font-Bold="true" Enabled="false" ForeColor="Red" runat="server" CssClass="form-control" OnTextChanged="ddlType_Change" AutoPostBack="true">
                                <asp:ListItem Value="Authorized">Authorized</asp:ListItem>
                                <asp:ListItem Value="Non Authorized">Non Authorized</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblGstNo" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>GST No :</asp:Label>
                            <asp:TextBox ID="txtGstNo" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" OnTextChanged="txtGstNo_TextChange" AutoPostBack="true" Style="text-transform: uppercase;"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Enter GST Number"
                                ControlToValidate="txtGstNo" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserFName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Full Name :</asp:Label>
                            <asp:TextBox ID="txtUserFName" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Full Name"
                                ControlToValidate="txtUserFName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblComName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Company Name :</asp:Label>
                            <asp:TextBox ID="txtComName" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Company Name"
                                ControlToValidate="txtComName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblEmailID" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Email ID :</asp:Label>
                            <asp:TextBox ID="txtEmailID" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" OnTextChanged="txtEmailId_TextChange" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Email ID"
                                ControlToValidate="txtEmailID" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMobileNo" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Mobile No :</asp:Label>
                            <asp:TextBox ID="txtMobileNo" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" MaxLength="10" onkeypress="return (event.charCode >= 48 && event.charCode <= 57)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Mobile Number"
                                ControlToValidate="txtMobileNo" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblPanCard" runat="server" Font-Bold="true" CssClass="form-label">PanCard No :</asp:Label>
                            <asp:TextBox ID="txtPanCard" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUANNo" runat="server" Font-Bold="true" CssClass="form-label">UAN No :</asp:Label>
                            <asp:TextBox ID="txtUANNo" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <h5 class="fw-bold">Billing Details</h5>
                    <hr />
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillAddress" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing Address :</asp:Label>
                            <asp:TextBox TextMode="MultiLine" ID="txtBillAddress" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ErrorMessage="Please Enter Billing Address"
                                ControlToValidate="txtBillAddress" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillPinCode" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing PIN Code :</asp:Label>
                            <asp:TextBox ID="txtBillPinCode" runat="server" MaxLength="6" onkeypress="return (event.charCode >= 48 && event.charCode <= 57)" CssClass="form-control" onchange="bindPinInfo(this)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ErrorMessage="Please Enter Billing PIN Code"
                                ControlToValidate="txtBillPinCode" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillArea" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing Area :</asp:Label>
                            <asp:TextBox ID="txtBillArea" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ErrorMessage="Please Enter Billing Area"
                                ControlToValidate="txtBillArea" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillCity" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing City :</asp:Label>
                            <asp:TextBox ID="txtBillCity" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ErrorMessage="Please Enter Billing City"
                                ControlToValidate="txtBillCity" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillState" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing State :</asp:Label>
                            <asp:TextBox ID="txtBillState" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ErrorMessage="Please Enter Billing State"
                                ControlToValidate="txtBillState" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblBillCountry" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Billing Country :</asp:Label>
                            <asp:TextBox ID="txtBillCountry" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ErrorMessage="Please Enter Billing Country"
                                ControlToValidate="txtBillCountry" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <h5 class="fw-bold">Shipping Details</h5>
                    <span>
                        <asp:CheckBox ID="check_address" OnCheckedChanged="check_address_CheckedChanged" AutoPostBack="true" runat="server" />
                        <asp:Label ID="Label2" runat="server">Copy Billing Details</asp:Label></span>
                    <hr />
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblshipAddress" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping Address :</asp:Label>
                            <asp:TextBox TextMode="MultiLine" ID="txtShipAddress" runat="server" CssClass="form-control" ></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ErrorMessage="Please Enter Shipping Address"
                                ControlToValidate="txtShipAddress" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblShipPinCode" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping PIN Code :</asp:Label>
                            <asp:TextBox ID="txtShipPinCode" runat="server" CssClass="form-control" onkeypress="return (event.charCode >= 48 && event.charCode <= 57)" MaxLength="6" onchange="bindSPinInfo(this)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ErrorMessage="Please Enter Shipping PIN Code"
                                ControlToValidate="txtShipPinCode" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblShipArea" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping Area :</asp:Label>
                            <asp:TextBox ID="txtShipArea" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ErrorMessage="Please Enter Shipping Area"
                                ControlToValidate="txtShipArea" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblShipCity" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping City :</asp:Label>
                            <asp:TextBox ID="txtShipCity" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ErrorMessage="Please Enter Shipping City"
                                ControlToValidate="txtShipCity" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblShipState" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping State :</asp:Label>
                            <asp:TextBox ID="txtShipState" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator16" runat="server" ErrorMessage="Please Enter Shipping State"
                                ControlToValidate="txtShipState" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblShipCountry" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Shipping Country :</asp:Label>
                            <asp:TextBox ID="txtShipCountry" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator17" runat="server" ErrorMessage="Please Enter Shipping Country"
                                ControlToValidate="txtShipCountry" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />
                    <hr />
                    <center>
                        <div>
                            <asp:HiddenField ID="hdnVal" runat="server" />
                            <asp:HiddenField ID="hdnPass" runat="server" />
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
                        </div>
                    </center>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TransporterMaster.aspx.cs" Inherits="Admin_TransporterMaster" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .spncls {
            color: red;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Transporter</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btnDeList_Click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserFName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Transporter Name :</asp:Label>
                            <asp:TextBox ID="txtTransporeteFName" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Transporter Name"
                                ControlToValidate="txtTransporeteFName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblTransportercode" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Transporter code :</asp:Label>
                            <asp:TextBox ID="txtTransportercode" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Transporter code"
                                ControlToValidate="txtTransportercode" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>


                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblGstNo" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>GST No :</asp:Label>
                            <asp:TextBox ID="txtGstNo" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Enter GST Number"
                                ControlToValidate="txtGstNo" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblPanCard" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>PanCard No :</asp:Label>
                            <asp:TextBox ID="txtPanCard" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator18" runat="server" ErrorMessage="Please Enter PanCard Number"
                                ControlToValidate="txtPanCard" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblEmailID" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Email ID :</asp:Label>
                            <asp:TextBox ID="txtEmailID" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Email ID"
                                ControlToValidate="txtEmailID" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblcontactperson" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Contact Person:</asp:Label>
                            <asp:TextBox ID="txtcontactperson" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator19" runat="server" ErrorMessage="Please Enter Contact Person"
                                ControlToValidate="txtcontactperson" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                    </div>
                    <div class="row">

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMobileNo" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Mobile No :</asp:Label>
                            <asp:TextBox ID="txtMobileNo" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Mobile Number"
                                ControlToValidate="txtMobileNo" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lbladdress" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Address :</asp:Label>
                            <asp:TextBox ID="txtaddress" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ErrorMessage="Please Enter Address"
                                ControlToValidate="txtaddress" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblcity" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>City :</asp:Label>
                            <asp:TextBox ID="Txtcity" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ErrorMessage="Please Enter City"
                                ControlToValidate="Txtcity" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>


                        <div class="col-md-4 col-12">
                            <asp:Label ID="Lblstate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>State :</asp:Label>
                            <asp:TextBox ID="txtstate" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ErrorMessage="Please Enter state"
                                ControlToValidate="txtstate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="Lblpincode" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Pincode :</asp:Label>
                            <asp:TextBox ID="txtpincode" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ErrorMessage="Please Enter Pincode"
                                ControlToValidate="txtpincode" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblvehical" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Vehical Type :</asp:Label>
                            <asp:TextBox ID="txtvehical" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ErrorMessage="Please Enter Vehical Type"
                                ControlToValidate="txtvehical" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblratekm" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Rate/Km  :</asp:Label>
                            <asp:TextBox ID="txtratekm" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ErrorMessage="Please Enter Rate/Km"
                                ControlToValidate="txtratekm" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblservicearea" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>ServiceRoute :</asp:Label>
                            <asp:TextBox ID="txtServiceRoute" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" placeholder="Example:Pune to Nashik"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ErrorMessage="Please Service Route"
                                ControlToValidate="txtServiceRoute" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="Lblbankname" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Bank Name  :</asp:Label>
                            <asp:TextBox ID="txtbankname" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ErrorMessage="Please Enter Bank Name"
                                ControlToValidate="txtbankname" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>


                        <div class="col-md-4 col-12">
                            <asp:Label ID="LblIFSC" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>IFSC Code:</asp:Label>
                            <asp:TextBox ID="txtifsc" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ErrorMessage="Please Enter IFSC Code"
                                ControlToValidate="txtifsc" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblaccountno" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Account No:</asp:Label>
                            <asp:TextBox ID="txtaccountno" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ErrorMessage="Please Enter Account No."
                                ControlToValidate="txtaccountno" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <hr />
                    <center>
                        <div>
                            <asp:HiddenField ID="hdnVall" runat="server" />
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btnsave_Click"></asp:LinkButton>
                        </div>
                    </center>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

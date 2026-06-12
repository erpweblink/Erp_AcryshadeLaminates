<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" Async="true" CodeFile="UserMaster.aspx.cs" Inherits="UserMaster" %>


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
                    <h3 class="m-0 font-weight-bold"><b>User</b></h3>
                    <asp:Button ID="btnUsList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_UsList_click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserFName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Full Name :</asp:Label>
                            <asp:TextBox ID="txtUserFName" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Full Name"
                                ControlToValidate="txtUserFName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserMail" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Email Id :</asp:Label>
                            <asp:TextBox ID="txtUserMail" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"  OnTextChanged="txtEmailId_TextChange" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Email Address"
                                ControlToValidate="txtUserMail" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserPassword" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Password :</asp:Label>
                            <asp:TextBox ID="txtUserPassword" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Password"
                                ControlToValidate="txtUserPassword" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblUserCnt" runat="server" Font-Bold="true" CssClass="form-label">Mobile Number :</asp:Label>
                            <asp:TextBox ID="txtUserCnt" runat="server" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblRole" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Role :</asp:Label>
                            <asp:DropDownList ID="ddlRoles" runat="server" CssClass="form-control">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Select Role"
                                ControlToValidate="ddlRoles" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />
                    <hr />
                    <center>
                        <div>
                             <asp:HiddenField ID="hdnId" runat="server" />
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
                        </div>
                    </center>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

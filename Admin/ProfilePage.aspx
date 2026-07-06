<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ProfilePage.aspx.cs" Inherits="ProfilePage" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .profile-card {
            max-width: 700px;
            margin: 40px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            padding: 30px;
        }

        .profile-img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #0d6efd;
        }

        .title {
            font-weight: 600;
            color: #0d6efd;
            margin-bottom: 20px;
        }

        .btn-save {
            width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="container">

        <div class="profile-card">

            <h3 class="text-center title">My Profile</h3>
            <div class="row">

                <div class="col-md-6 mb-3">
                    <label>Full Name</label>
                    <asp:TextBox ID="txtName"
                        runat="server"
                        CssClass="form-control"></asp:TextBox>
                    <asp:RequiredFieldValidator
                        ID="rfvName"
                        runat="server"
                        ControlToValidate="txtName"
                        ValidationGroup="Profile"
                        ErrorMessage="Full Name is required."
                        CssClass="text-danger"
                        Display="Dynamic" />
                </div>

                <div class="col-md-6 mb-3">
                    <label>Email ID</label>
                    <asp:TextBox ID="txtUsername"
                        runat="server"
                        CssClass="form-control" AutoPostBack="true"
                        OnTextChanged="txtEmail_TextChanged"></asp:TextBox>

                    <asp:RequiredFieldValidator
                        ID="rfvEmail"
                        runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Email is required."
                        CssClass="text-danger"
                        Display="Dynamic">
    </asp:RequiredFieldValidator>

                    <asp:RegularExpressionValidator
                        ID="revEmail"
                        runat="server"
                        ControlToValidate="txtUsername"
                        ValidationExpression="^\w+([-.+']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                        ErrorMessage="Enter a valid email address."
                        CssClass="text-danger"
                        Display="Dynamic">
    </asp:RegularExpressionValidator>

                    <asp:CustomValidator
                        ID="cvEmail"
                        runat="server"
                        ControlToValidate="txtUsername"
                        ErrorMessage="Email already exists."
                        CssClass="text-danger"
                        Display="Dynamic"
                        EnableClientScript="false">
    </asp:CustomValidator>
                </div>

                <div class="col-md-6 mb-3">
                    <label>Password</label>
                    <asp:TextBox ID="txtPassword"
                        runat="server"
                        CssClass="form-control"></asp:TextBox>

                    <asp:RequiredFieldValidator
                        ID="rfvPassword"
                        runat="server"
                        ControlToValidate="txtPassword"
                        ValidationGroup="Profile"
                        ErrorMessage="Password is required."
                        CssClass="text-danger"
                        Display="Dynamic" />

                </div>

                <div class="col-md-6 mb-3">
                    <label>Mobile Number</label>
                    <asp:TextBox ID="txtMobile"
                        runat="server"
                        CssClass="form-control"></asp:TextBox>
                </div>

                <div class="col-md-12 mt-3">

                    <asp:Button
                        ID="btnUpdate"
                        runat="server"
                        Text="Update Profile"
                        ValidationGroup="Profile"
                        CausesValidation="true"
                        CssClass="btn btn-primary btn-save"
                        OnClick="btnUpdate_Click" />

                </div>

                <div class="col-md-12 mt-3 text-center">

                    <asp:Label
                        ID="lblMessage"
                        runat="server"
                        ForeColor="Green"
                        Font-Bold="true"></asp:Label>

                </div>

            </div>

        </div>

    </div>
</asp:Content>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>




<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Designed for Acryshade Laminates Pvt. Ltd.">
    <title>Acryshade Laminates</title>
    <link rel="stylesheet" href="../Content/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="../Content/assets/vendors/bootstrap-icons/bootstrap-icons.css">
    <link rel="stylesheet" href="../Content/assets/css/login.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.js"></script>
</head>
<body>
    <div class="animated-bg"></div>
    <div class="bg-overlay"></div>
    <form id="form1" runat="server">
        <section class="login-block multiclr">
            <div class="container">
                <div class="row border-solid">
                    <div class="col-md-12">
                        <div class="md-float-material form-material">
                            <div class="auth-box card" style="max-width: 385px;">
                                <div class="card-block">
                                    <div class="row m-b-20">
                                        <div class="col-md-12">
                                            <h3 class="text-center">Sign In</h3>
                                        </div>
                                    </div>
                                    <br />
                                    <div class="form-group form-primary">
                                        <asp:TextBox ID="txtUsername" runat="server" class="form-control" placeholder="Your Email Address" autocomplete="off"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" Display="Dynamic" ErrorMessage="Please Enter Your Email Address"
                                            ControlToValidate="txtUsername" ValidationGroup="form1" ForeColor="Red" SetFocusOnError="true"></asp:RequiredFieldValidator>
                                        <span class="form-bar"></span>
                                    </div>
                                    <div class="form-group form-primary mt-3">
                                        <asp:TextBox ID="txtPassword" runat="server" class="form-control" placeholder="Password" TextMode="Password" autocomplete="off"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Display="Dynamic" ErrorMessage="Please Enter Your Password"
                                            ControlToValidate="txtPassword" ValidationGroup="form1" ForeColor="Red" SetFocusOnError="true"></asp:RequiredFieldValidator>
                                        <span class="form-bar"></span>
                                    </div>
                                    <div class="row m-t-25 text-left">
                                        <div class="col-12">
                                            <div class="checkbox-fade fade-in-primary d-">
                                                <label>
                                                    <asp:CheckBox ID="chkremember" runat="server" />
                                                    <span class="cr"><i class="cr-icon icofont icofont-ui-check txt-primary"></i></span>
                                                    <span class="text-inverse">Remember me</span>
                                                </label>
                                            </div>
                                            <div class="forgot-phone text-right f-right">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row m-t-20">
                                        <div class="col-md-12">
                                            <asp:Button ID="btnsave" OnClick="btnsave_Click" runat="server" Text="Sign in" ValidationGroup="form1" CssClass="btn btn-light-primary btn-md btn-block waves-effect waves-light text-center m-b-2" />
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <a href="https://www.acryshadelaminates.com/">
                                        <img src="../Content/assets/images/CompanyLogo/logo.png" alt="logo" />
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </form>
</body>
</html>

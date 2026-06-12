<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ProductMaster.aspx.cs" Inherits="Admin_ProductMaster" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
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
    </style>
    <script type="text/javascript">
        function validateFileSize(input) {
            if (input.files && input.files[0]) {
                var fileSize = input.files[0].size;
                var maxSize = 5 * 1024 * 1024;
                if (fileSize > maxSize) {
                    alert("Please upload image below 5 MB only.";
                    input.value = "";
                    return false;
                }
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Product</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btnDeList_Click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblprodcutcode" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Product code:</asp:Label>
                            <asp:TextBox ID="txtproductcode" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Product Code"
                                ControlToValidate="txtproductcode" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblproductname" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Product Name:</asp:Label>
                            <asp:TextBox ID="txtproductname" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" ForeColor="Red" Font-Bold="true"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetProductnameList"
                                TargetControlID="txtproductname" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Product Name"
                                ControlToValidate="txtproductname" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblThickness" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Sheet Thickness (MM):</asp:Label>
                            <asp:TextBox ID="txtThickness" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Enter Thikness"
                                ControlToValidate="txtThickness" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="Label2" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Item Code:</asp:Label>
                            <asp:TextBox ID="txtpartno" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ErrorMessage="Please Enter Item Code."
                                ControlToValidate="txtpartno" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblpartname" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Part Name:</asp:Label>
                            <asp:TextBox ID="txtpartname" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Part Name"
                                ControlToValidate="txtpartname" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">
                               <span class="spncls">*</span> Size :
                            </asp:Label>

                            <asp:DropDownList ID="ddlSize" runat="server" CssClass="form-control" ValidationGroup="001">
                                <asp:ListItem Value="">-- Select Part Name --</asp:ListItem>
                                <asp:ListItem Value="2x4">2 x 4</asp:ListItem>
                                <asp:ListItem Value="2x8">2 x 8</asp:ListItem>
                                <asp:ListItem Value="4x8">4 x 8</asp:ListItem>
                            </asp:DropDownList>

                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                                ErrorMessage="Please Select Part Name"
                                ControlToValidate="ddlSize"
                                InitialValue=""
                                ForeColor="Red"
                                SetFocusOnError="true"
                                ValidationGroup="001">
                            </asp:RequiredFieldValidator>
                        </div>

                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMCImage" runat="server" Font-Bold="true" CssClass="form-label">Attach Image:</asp:Label>
                            <asp:FileUpload ID="FileMCImage" runat="server" CssClass="form-control" accept=".jpg,.jpeg,.png,.gif" onchange="validateFileSize(this)" />
                            <small class="text-danger d-block mt-1">Maximum file size: 5 MB</small>
                            <div class="mt-3 text-center">
                                <asp:Image ID="imgPreview" runat="server" Width="150px" Height="150px" Visible="false" CssClass="img-thumbnail" />
                                <br />
                                <asp:Label ID="lblUploadedName" runat="server" Font-Bold="true" Visible="false" CssClass="d-block mt-2 text-break"></asp:Label>
                            </div>
                        </div>
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
            <asp:PostBackTrigger ControlID="btnDeList" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="MachineMaster.aspx.cs" Inherits="MachineMaster" %>


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
                    alert("Please upload image below 5 MB only.");
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
                    <h3 class="m-0 font-weight-bold"><b>Machine</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_DeList_click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMachineName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Machine Name:</asp:Label>
                            <asp:TextBox ID="txtMachineName" Font-Bold="true" ForeColor="Red" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetMachineList"
                                TargetControlID="txtMachineName" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Machine Name"
                                ControlToValidate="txtMachineName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMCDesc" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Machine Description:</asp:Label>
                            <asp:TextBox ID="txtMCDesc" TextMode="MultiLine" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Machine Description"
                                ControlToValidate="txtMCDesc" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblMCPerHrQty" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Per Hour Capacity:</asp:Label>
                            <asp:TextBox ID="txtMCPerHrQty" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" onkeypress="return ((event.charCode >= 48 && event.charCode <= 57) || event.charCode == 46)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Per Hour Capacity"
                                ControlToValidate="txtMCPerHrQty" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblRunHr" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Running Hours:</asp:Label>
                            <asp:TextBox ID="txtRunHr" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" onkeypress="return ((event.charCode >= 48 && event.charCode <= 57) || event.charCode == 46)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Machine Running Hours"
                                ControlToValidate="txtRunHr" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4 col-12">
                            <asp:Label ID="lblStage" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Stage Name:</asp:Label>
                            <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-control">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Select Stage Name"
                                ControlToValidate="ddlStage" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
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
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
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

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="StageMaster.aspx.cs" Inherits="StageMaster" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
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
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Stage</b></h3>
                    <asp:Button ID="btnDeList" CssClass="btn btn-outline-danger" Font-Bold="true" Text="List" CausesValidation="false" runat="server" OnClick="btn_DeList_click" />
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 col-12">
                            <asp:Label ID="lblStageName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Stage Name:</asp:Label>
                            <asp:TextBox ID="txtStageName" Font-Bold="true" ForeColor="Red" runat="server" CssClass="form-control" AutoComplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetStageList"
                                TargetControlID="txtStageName" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Stage Name"
                                ControlToValidate="txtStageName" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3 col-12">
                            <asp:Label ID="lblStageDesc" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Stage Description:</asp:Label>
                            <asp:TextBox ID="txtStageDesc" TextMode="MultiLine" runat="server" AutoComplete="off" ValidationGroup="001" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Stage Description"
                                ControlToValidate="txtStageDesc" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3 col-12">
                            <asp:Label ID="lblStageCapi" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Stage Capacity:</asp:Label>
                            <asp:TextBox ID="txtStageCapi" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Stage Capacity"
                                ControlToValidate="txtStageCapi" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3 col-12">
                            <asp:Label ID="lblCapiUnit" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Unit:</asp:Label>
                            <asp:TextBox ID="txtCapiUnit" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetUnitList"
                                TargetControlID="txtCapiUnit" Enabled="true">
                            </asp:AutoCompleteExtender>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Capacity Unit"
                                ControlToValidate="txtCapiUnit" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
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
    </asp:UpdatePanel>
</asp:Content>

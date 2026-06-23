<%@ Page Language="C#" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ProductionTrackingReports.aspx.cs" Inherits="ProductionTrackingReports" MasterPageFile="~/MasterPage.master" %>



<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Production Tracking Report</b></h3>
                    <asp:Button ID="btnExportExcel" runat="server" Text="Export To Excel"
                        CssClass="btn btn-outline-success" OnClick="btnExportExcel_Click" />
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="GVdetails" runat="server" DataKeyNames="ID" OnRowDataBound="GVdetails_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVdetails_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder No" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderNo" runat="server" Text='<%#Eval("WorkOrderNo")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Product Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblProductName" runat="server" Text='<%#Eval("ProductName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Part No" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPartNo" runat="server" Text='<%#Eval("PartNo")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Size" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSize" runat="server" Text='<%#Eval("Size")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Received Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblLoginReceivedQty" runat="server" Text='<%#Eval("ReceivedQty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Balance Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblBalanceqty" runat="server" Text='<%#Eval("Balanceqty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Rejected Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblRejectedQty" runat="server" Text='<%#Eval("RejectedQty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWOStatus" runat="server" Text='<%#Eval("WOStatus")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Stage" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblAllocatedStage" runat="server" Text='<%#Eval("AllocatedStage")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportExcel" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

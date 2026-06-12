<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WorkOrdrForDesign.aspx.cs" Inherits="WorkOrdrForDesign" MasterPageFile="~/MasterPage.master" %>

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
                    <h3 class="m-0 font-weight-bold"><b>Approve Designs</b></h3>
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Dealer Name :</asp:Label>
                            <asp:TextBox ID="txtcompanyname" CssClass="form-control" runat="server" Width="100%" OnTextChanged="txtcompanyname_TextChanged" AutoPostBack="true"></asp:TextBox>
                            <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCompanyList"
                                TargetControlID="txtcompanyname" Enabled="true">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="col-md-1">
                            <asp:LinkButton ID="btnrefresh" runat="server"
                                OnClick="btnrefresh_Click" CssClass="btn btn-outline-danger"> 
                   <i class="bi bi-arrow-clockwise" ></i>
                            </asp:LinkButton>
                        </div>
                        <div class="col-md-8 d-flex justify-content-end">
                            <div style="width: 120px;">
                                <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                    <asp:ListItem Text="10" Value="10" Selected="True" />
                                    <asp:ListItem Text="50" Value="50" />
                                    <asp:ListItem Text="All" Value="0" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <hr />
                    <div class="table-responsive">
                        <asp:GridView ID="Gvdetails" runat="server" DataKeyNames="ID" OnRowDataBound="Gvdetails_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="Gvdetails_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder No" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkWorkOrderNo" runat="server"
                                            Text='<%# Eval("WorkOrderNo") %>' Font-Bold="true"
                                            CommandName="ViewWorkOrder"
                                            CommandArgument='<%# Eval("ID") %>'
                                            CssClass="text-primary btn-link">
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderDate" runat="server" Text='<%#Eval("WorkOrderDate")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDealer" runat="server" Text='<%#Eval("Dealer")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCustomerName" runat="server" Text='<%#Eval("CustomerName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Attachment" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btn_View_aattach" runat="server" CommandName="RowPO" CommandArgument='<%# Eval("AttachmentPath") %>'
                                            ForeColor='<%# string.IsNullOrEmpty(Convert.ToString(Eval("AttachmentPath"))) ? System.Drawing.Color.Red : System.Drawing.Color.FromArgb(13,110,253) %>'
                                            Enabled='<%# string.IsNullOrEmpty(Convert.ToString(Eval("AttachmentPath"))) ? false:true %>'
                                            ToolTip="Open File"><i class="bi-file-earmark-medical"  style="font-size:26px;"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btApproved" runat="server"
                                            ToolTip="Approve" CommandName="Approved"
                                            CommandArgument='<%#Eval("ID")%>'
                                            CssClass="btn btn-outline-info btn-sm"
                                            Visible='<%# string.IsNullOrWhiteSpace(Eval("isdesignapproved").ToString())?true:false %>'>
                                            <i class="bi bi-check-lg"></i>
                                        </asp:LinkButton>
                                        &nbsp;&nbsp;
                                        <asp:LinkButton ID="btDisapproved" runat="server"
                                            ToolTip="Disapprove"
                                            CommandName="DisApproved"
                                            CommandArgument='<%# Eval("ID") %>'
                                            CssClass="btn btn-outline-danger btn-sm"
                                            Visible='<%# string.IsNullOrWhiteSpace(Eval("isdesignapproved").ToString())?true:false %>'>
                                             <i class="bi bi-x-lg"></i>
                                        </asp:LinkButton>
                                        <asp:Label ID="lblVal" runat="server" 
                                            Visible='<%# !string.IsNullOrWhiteSpace(Eval("isdesignapproved").ToString())?true:false %>' 
                                            Text='<%#Eval("isdesignapproved").ToString() == "True"?"Approved":"Not Approved" %>'
                                            ForeColor='<%#Eval("isdesignapproved").ToString() == "True"? System.Drawing.Color.Green : System.Drawing.Color.Red %>'
                                            Font-Bold="true">
                                        </asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="modal fade" id="detailsModal" tabindex="-1" role="dialog" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content modelprofile1" style="background: linear-gradient(65deg, #4e83c5 0%, #d7deeff0 42%, #4976a359 100%);">
                                <!-- HEADER -->
                                <div class="modal-header headingcls d-flex align-items-center">
                                    <h5 class="modal-title mb-0">Work Order Details
                                    </h5>
                                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="modal"></button>
                                </div>

                                <div class="modal-body">
                                    <div class="table-responsive">
                                        <asp:GridView ID="GvPopup" runat="server" CssClass="table table-bordered table-striped table-sm" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="table-dark" AutoGenerateColumns="false">
                                            <Columns>
                                                <asp:BoundField DataField="ProductName" HeaderText="Product Name" ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField DataField="PartNo" HeaderText="Part No" ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField DataField="Description" HeaderText="Description" ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField DataField="Size" HeaderText="Size" ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField DataField="Unit" HeaderText="Unit" ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField DataField="Qty" HeaderText="Qty" ItemStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

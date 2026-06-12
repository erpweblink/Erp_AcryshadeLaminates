<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ReceivedWOList.aspx.cs" Inherits="ReceivedWOList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Scheduler List</b></h3>
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-12 d-flex justify-content-end">
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
                        <asp:Button ID="btnReloadGrid" runat="server" OnClick="btnReloadGrid_Click" Style="display: none;" />
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Scheduled No" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder No" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="180">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkWorkOrderNo" runat="server"
                                            Text='<%# Eval("WorkOrderNo") %>' Font-Bold="true"
                                            CommandName="ViewWorkOrder" CommandArgument='<%# Eval("ID") %>'
                                            CssClass="text-primary btn-link">
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dealer name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDealer" runat="server" Text='<%#Eval("Dealer")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCustomerName" runat="server" Text='<%#Eval("CustomerName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderDate" runat="server" Text='<%#Eval("WorkOrderDate")%>'></asp:Label>
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
    <script type="text/javascript">
       function enableDragDrop() {
            var $table = $("#<%= GVCompany.ClientID %>");
            $table.find("tbody").sortable({
                items: "tr.drag-row",
                cursor: "move",
                axis: "y",
                update: function () {
                    var list = [];
                    $table.find("tbody tr.drag-row").each(function (index) {
                        list.push({
                            id: parseInt($(this).attr("data-id")),
                            rank: index + 1
                        });
                    });
                    $.ajax({
                        type: "POST",
                        url: "ReceivedWOList.aspx/UpdateRank",
                        data: JSON.stringify({ list: list }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function () {
                            document.getElementById('<%= btnReloadGrid.ClientID %>').click();
                        }
                    });
                }
            });
        }
        // Initial load
        $(document).ready(function () {
            enableDragDrop();
        });

        // After UpdatePanel refresh
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            enableDragDrop();
        });
    </script>
</asp:Content>

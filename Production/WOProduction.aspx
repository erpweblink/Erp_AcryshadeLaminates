<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="WOProduction.aspx.cs" Inherits="WOProduction" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style type="text/css">
        .spncls {
            color: red;
        }
    </style>
    <script type="text/javascript">
        function validateQty(ctrl, receivedQty, completedQty, rejectedQty) {

            var enteredQty = parseInt(ctrl.value) || 0;

            var balanceQty = receivedQty - completedQty - rejectedQty;

            if (enteredQty > balanceQty) {
                alert("Qty cannot exceed available quantity (" + balanceQty + ")");
                ctrl.value = "";
                ctrl.focus();
            }
        }
        function validateBtns(btn) {
            var txtQty = $(btn).closest("tr").find("input[id*='txtQty']");

            if ($.trim(txtQty.val()) === "") {
                alert("Please enter quantity.");
                txtQty.focus();
                return false;
            }

            return true;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>First Stage Production</b></h3>
                    <span id="spnAdmin" runat="server" visible="false">
                        <asp:DropDownList ID="ddlOperators" runat="server" Font-Bold="true" CssClass="form-control" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlOperators_SelectedIndexChanged" AutoPostBack="true">
                            <asp:ListItem Value="">--Select Operator--</asp:ListItem>
                        </asp:DropDownList>
                    </span>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- Column 1 -->
                        <div class="col-md-4">
                            <div><b>Date: </b><span id="spdate" runat="server"></span></div>
                            <div><b>Shift: </b><span id="spshift" runat="server"></span></div>
                            <div><b>Operator: </b><span id="spoperator" runat="server"></span></div>
                            <div><b>Machine: </b><span id="spmachine" runat="server"></span></div>
                            <div class="mt-3 p-2 border rounded bg-light">
                                <b>Note:</b><br />
                                <span style="color: red">Enter downtime details carefully.</span><br />
                                <span style="color: red">Reason is mandatory.</span>

                                <asp:ValidationSummary ID="ValidationSummary1"
                                    runat="server"
                                    ValidationGroup="F100"
                                    ForeColor="Red"
                                    HeaderText="Please correct the following errors:"
                                    DisplayMode="BulletList" />
                            </div>
                        </div>

                        <!-- Column 2 -->
                        <div class="col-md-4">
                            <div><b>Target: </b><span id="sptarget" runat="server"></span></div>
                            <div><b>Completed Qty: </b><span id="spprod" runat="server"></span></div>
                            <div><b>Rejected Qty: </b><span id="sprej" runat="server"></span></div>
                            <div class="mt-4">
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                    runat="server" Display="None"
                                    ErrorMessage="Please Select Start Date and Time"
                                    ControlToValidate="txtStarttime"
                                    ValidationGroup="F100"
                                    ForeColor="Red" />

                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2"
                                    runat="server" Display="None"
                                    ErrorMessage="Please Select End Date and Time"
                                    ControlToValidate="txtEndtime"
                                    ValidationGroup="F100"
                                    ForeColor="Red" />

                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3"
                                    runat="server" Display="None"
                                    ErrorMessage="Please Enter Reason"
                                    ControlToValidate="spdtend"
                                    ValidationGroup="F100"
                                    ForeColor="Red" />


                            </div>
                        </div>

                        <!-- Column 3 -->
                        <div class="col-md-4">
                            <div>
                                <b>Down Time Start:</b><span class="spncls">*</span>
                                <asp:TextBox TextMode="DateTimeLocal" ID="txtStarttime" ValidationGroup="F100" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div>
                                <b>Down Time End:</b><span class="spncls">*</span>
                                <asp:TextBox TextMode="DateTimeLocal" ID="txtEndtime" ValidationGroup="F100" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div>
                                <b>Reason:</b><span class="spncls">*</span>
                                <asp:TextBox TextMode="MultiLine" ID="spdtend" ValidationGroup="F100" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="text-end mt-1">
                                <asp:Button ID="btnSaveDowntime" runat="server" ValidationGroup="F100"
                                    Text="💾 Save Down Time" CssClass="btn btn-primary btn-sm shadow" />
                            </div>
                        </div>
                    </div>
                    <br />
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
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ProduID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="W/O No" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWONo" runat="server" Text='<%#Eval("WONo")%>'></asp:Label>
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
                                        <asp:Label ID="lblQty" runat="server" Text='<%#Eval("Qty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Completed Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCompletedQty" runat="server" Text='<%#Eval("CompletedQty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Rejected Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblRejectedQty" runat="server" Text='<%#Eval("RejectedQty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Enter Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtQty" runat="server" CssClass="form-control"
                                            Style="width: 70px; display: inline-block;" autocomplete="off"
                                            onkeyup='<%# "validateQty(this," + Eval("Qty") + "," + Eval("CompletedQty") + "," + Eval("RejectedQty") + ")" %>'>
                                        </asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnApprove" runat="server" CommandArgument='<%# Eval("ProduID") %>'
                                            CommandName="AppQty" ToolTip="Approve Qty" CssClass="btn btn-outline-success" Style="display: inline-block;" OnClientClick="return validateBtns(this);">
                                             <i class="bi-hand-thumbs-up"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnReject" runat="server" CommandArgument='<%# Eval("ProduID") %>'
                                            CommandName="RejQty" ToolTip="Reject Qty" CssClass="btn btn-outline-danger" Style="display: inline-block;" OnClientClick="return validateBtns(this);">
                                             <i class="bi bi-hand-thumbs-down"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

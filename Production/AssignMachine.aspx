<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignMachine.aspx.cs" Inherits="AssignMachine" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
        .spncls {
            color: red;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Assign Machine</b></h3>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <asp:Label ID="lblMcName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Machine Name:</asp:Label>
                            <asp:DropDownList ID="ddlMcName" Font-Bold="true" CssClass="form-control" runat="server" AppendDataBoundItems="true" ValidationGroup="001" OnSelectedIndexChanged="ddlMcName_SelectedIndexChanged" AutoPostBack="true">
                                <asp:ListItem Value="">--Select Machine Name --</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ErrorMessage="Please Select Machine"
                                ControlToValidate="ddlMcName" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-6">
                            <asp:Label ID="lblOpName" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Operator Name:</asp:Label>
                            <asp:DropDownList ID="ddlOpName" Font-Bold="true" CssClass="form-control" runat="server" AppendDataBoundItems="true" ValidationGroup="001" OnSelectedIndexChanged="ddlOpName_SelectedIndexChanged" AutoPostBack="true">
                                <asp:ListItem Value="">--Select Operator Name --</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Select Operator"
                                ControlToValidate="ddlOpName" ForeColor="Red" InitialValue="" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3">
                            <asp:Label ID="lblFromDate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>From Date:</asp:Label>
                            <asp:TextBox ID="txtFromDate" CssClass="form-control" runat="server" TextMode="Date" ValidationGroup="001"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Enter Date"
                                ControlToValidate="txtFromDate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3">
                            <asp:Label ID="lblToDate" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>To Date:</asp:Label>
                            <asp:TextBox ID="txtToDate" CssClass="form-control" runat="server" TextMode="Date" ValidationGroup="001"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ErrorMessage="Please Enter Date"
                                ControlToValidate="txtToDate" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3">
                            <asp:Label ID="lblFromTime" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>From Time:</asp:Label>
                            <asp:TextBox ID="txtFromTime" CssClass="form-control" runat="server" TextMode="Time" ValidationGroup="001"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ErrorMessage="Please Enter Time"
                                ControlToValidate="txtFromTime" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3">
                            <asp:Label ID="lblToTime" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>To Time:</asp:Label>
                            <asp:TextBox ID="txtToTime" CssClass="form-control" runat="server" TextMode="Time" ValidationGroup="001"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ErrorMessage="Please Enter Time"
                                ControlToValidate="txtToTime" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <hr />
                    <center>
                        <div>
                            <asp:LinkButton ID="btnsave" class="btn btn-outline-success me-3" ValidationGroup="001" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
                        </div>
                    </center>
                    <br />
                    <div class="table-responsive">
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Machine Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblMachineID" runat="server" Text='<%#Eval("MachineID")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="User Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOperatorID" runat="server" Text='<%#Eval("OperatorID")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="From Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblFromDate" runat="server" Text='<%#Eval("FromDate")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="To Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblToDate" runat="server" Text='<%#Eval("ToDate")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="From Time" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblFromTime" runat="server" Text='<%#Eval("FromTime")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="To Time" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblToTime" runat="server" Text='<%#Eval("ToTime")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnDelete" runat="server" ToolTip="Delete Company" CommandName="RowDelete" OnClientClick="Javascript:return confirm('Are you sure to Delete?')" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-danger  btn-sm"><i class='bi bi-trash3-fill'></i></asp:LinkButton>
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

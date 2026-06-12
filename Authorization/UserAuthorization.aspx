<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="UserAuthorization.aspx.cs" Inherits="UserAuthorization" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>User Authorization</b></h3>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblUserRole" runat="server" Font-Bold="true" CssClass="form-label">User Role:</asp:Label>
                            <asp:DropDownList ID="ddlUserRole" runat="server" CssClass="form-control" Font-Bold="true" ForeColor="Red" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlUserRole_SelectedIndexChanged" AutoPostBack="true">
                                <asp:ListItem Text="--Select Role--" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6 col-12">
                            <asp:Label ID="lblUserName" runat="server" Font-Bold="true" CssClass="form-label">User Name:</asp:Label>
                            <asp:DropDownList ID="ddlUserName" runat="server" CssClass="form-control" Font-Bold="true" ForeColor="Red" OnSelectedIndexChanged="ddlUserName_SelectedIndexChanged" AutoPostBack="true">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <br />
                    <br />
                    <div id="GridDiv" runat="server">
                        <div class="table-responsive">
                            <asp:GridView ID="gvUserAuthorization" runat="server" EmptyDataText="No records found" DataKeyNames="UID" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" 
                                OnRowDataBound="gvUserAuthorization_RowDataBound">  
                                <Columns>
                                    <asp:TemplateField HeaderText="Sr. No." ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="80">
                                        <ItemTemplate>
                                            <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Page Name" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblMenuName" runat="server" Text='<%# Eval("MenuName") %>'></asp:Label>
                                            <asp:Label ID="lblMenuId" runat="server" CssClass="d-none" Text='<%# Eval("MenuId") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Menu Name" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Label ID="lblPageName" runat="server" Text='<%# Eval("PageName") %>'></asp:Label>
                                            <asp:Label ID="lblPageAccess" CssClass="d-none" runat="server" Text='<%# Eval("PageAccess") %>'></asp:Label>
                                            <asp:Label ID="lblPageButtonAccess" CssClass="d-none" runat="server" Text='<%# Eval("PageButtonAccess") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Allow Access" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkPages" readonly="true" runat="server" name="chk" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Allow Edit" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkPagesView" readonly="true"  runat="server" name="chk" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView> 
                            <br />
                            <hr />
                            <center>
                                <div>
                                    <asp:LinkButton ID="btnSubmit" class="btn btn-outline-success me-3" runat="server" Text="Submit" OnClick="btnSubmit_Click"></asp:LinkButton>
                                </div>
                            </center>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

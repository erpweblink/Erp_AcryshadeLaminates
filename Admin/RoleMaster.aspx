<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="RoleMaster.aspx.cs" Inherits="RoleMaster" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
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
                    <h3 class="m-0 font-weight-bold"><b>Role</b></h3>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 col-12 mb-3">
                            <asp:Label ID="lblDepartment" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Department:</asp:Label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control">
                                <asp:ListItem Value="">--Select Department--</asp:ListItem>
                                <asp:ListItem Value="In-House">Acryshade</asp:ListItem>
                                <asp:ListItem Value="Outsourcing">Distributer</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Select Department"
                                ControlToValidate="ddlDepartment" ForeColor="Red" SetFocusOnError="true" InitialValue="" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-6 col-12 mb-3">
                            <asp:Label ID="lblrole" runat="server" Font-Bold="true" CssClass="form-label"><span class="spncls">*</span>Role:</asp:Label>
                            <asp:TextBox ID="txtRole" runat="server" ValidationGroup="001" AutoComplete="off" CssClass="form-control" OnTextChanged="txtRole_TextChanged" AutoPostBack="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please Enter Role"
                                ControlToValidate="txtRole" ForeColor="Red" SetFocusOnError="true" ValidationGroup="001"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <center>
                        <div>
                            <asp:LinkButton ID="btnsave" ValidationGroup="001" class="btn btn-outline-success me-3" runat="server" Text="Save" OnClick="btn_save_Click"></asp:LinkButton>
                        </div>
                    </center>
                    <br />
                    <br />
                    <h2>Role List</h2>
                    <hr />
                    <div class="table-responsive">
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Departments" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDepartments" runat="server" Text='<%#Eval("Departments").ToString() =="In-House"?"Acryshade":"Distributer"%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Role" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblRole" runat="server" Text='<%#Eval("Roles")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%--Are you sure to Delete?--%>
                                        <asp:LinkButton ID="btnDelete" runat="server" ToolTip="Delete Role" CommandName="RowDelete" Enabled="false" OnClientClick="Javascript:return confirm('This button is not activated')" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-danger  btn-sm"><i class='bi bi-trash3-fill'></i></asp:LinkButton>
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

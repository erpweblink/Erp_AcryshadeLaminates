<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TransporterList.aspx.cs" Inherits="Admin_TransporterList" MasterPageFile="~/MasterPage.master" %>

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
                 <h3 class="m-0 font-weight-bold"><b>Transporter List</b></h3>
                 <asp:Button ID="btnCreate" CssClass="btn btn-outline-primary" Font-Bold="true" Text="Create" CausesValidation="false"  OnClick="btnCreate_Click" runat="server" />
             </div>
             <div class="card-body">
                 <div class="row align-items-end">
                     <div class="col-md-3">
                         <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Transporter Name :</asp:Label>
                         <asp:TextBox ID="txttransportrename" CssClass="form-control" runat="server" Width="100%"  OnTextChanged="txttransportrename_TextChanged" AutoPostBack="true"></asp:TextBox>
                         <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                             CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                             CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCompanyList"
                             TargetControlID="txttransportrename" Enabled="true">
                         </asp:AutoCompleteExtender>
                     </div>
                     <div class="col-md-1">
                         <asp:LinkButton ID="btnrefresh" runat="server"
                             OnClick="btnrefresh_Click"  CssClass="btn btn-outline-danger"> 
                        <i class="bi bi-arrow-clockwise" ></i>
                         </asp:LinkButton>
                     </div>
                     <div class="col-md-8 d-flex justify-content-end">
                         <div style="width: 120px;">
                             <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged" >
                                 <asp:ListItem Text="10" Value="10" Selected="True" />
                                 <asp:ListItem Text="50" Value="50" />
                                 <asp:ListItem Text="All" Value="0" />
                             </asp:DropDownList>
                         </div>
                     </div>
                 </div>

                 <hr />
                 <div class="table-responsive">
                     <asp:GridView ID="GVDetails" runat="server" DataKeyNames="ID" OnRowDataBound="GVDetails_RowDataBound"  CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                         HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false"  OnRowCommand="GVDetails_RowCommand" >
                         <Columns>
                             <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                 <ItemTemplate>
                                     <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                 </ItemTemplate>
                             </asp:TemplateField>
                             <asp:TemplateField HeaderText="User Code" ItemStyle-HorizontalAlign="Center">
                                 <ItemTemplate>
                                     <asp:Label ID="lblUserCode" runat="server" Text='<%#Eval("transporter_code")%>'></asp:Label>
                                 </ItemTemplate>
                             </asp:TemplateField>
                             <asp:TemplateField HeaderText="Transporter Name" ItemStyle-HorizontalAlign="Center">
                                 <ItemTemplate>
                                     <asp:Label ID="lblFullName" runat="server" Text='<%#Eval("transporter_name")%>'></asp:Label>
                                 </ItemTemplate>
                             </asp:TemplateField>

                             <asp:TemplateField HeaderText="Email Id" ItemStyle-HorizontalAlign="Center">
                                 <ItemTemplate>
                                     <asp:Label ID="lblEmail" runat="server" Text='<%#Eval("email")%>'></asp:Label>
                                 </ItemTemplate>
                             </asp:TemplateField>
                    
                             <asp:TemplateField HeaderText="ACTION" ItemStyle-HorizontalAlign="Center">
                                 <ItemTemplate>
                                     <asp:LinkButton ID="btnEdit" runat="server" ToolTip="Edit Company" CommandName="RowEdit" CommandArgument='<%#Eval("ID")%>' CssClass="btn btn-outline-info  btn-sm"><i class='bi bi-pencil'></i></asp:LinkButton>
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

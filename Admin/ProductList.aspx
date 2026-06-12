<%@ Page Language="C#" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="ProductList.aspx.cs" Inherits="ProductList" MasterPageFile="~/MasterPage.master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
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

        /* Toggle switch */
        .switch {
            position: relative;
            display: inline-block;
            width: 36px;
            height: 18px;
        }

            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }

        .slider {
            position: absolute;
            cursor: pointer;
            background-color: #ccc;
            transition: .4s;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
        }

            .slider:before {
                position: absolute;
                content: "";
                height: 14px;
                width: 14px;
                left: 2px;
                bottom: 2px;
                background: white;
                transition: .4s;
            }

        input:checked + .slider {
            background-color: #28a745;
        }

            input:checked + .slider:before {
                transform: translateX(18px);
            }

        .slider.round {
            border-radius: 34px;
        }

            .slider.round:before {
                border-radius: 50%;
            }

        /* Responsive adjustments */
        @media (max-width:768px) {

            #UserModal .modal-dialog {
                max-width: 95%;
            }

            .user-table th,
            .user-table td {
                font-size: 12px;
                padding: 6px;
            }
        }

        /*CSS fro Image Pop UP*/
        .product-image-preview {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
        }

        .image-hover-container {
            display: inline-block;
        }

        .image-popup {
            display: none;
            position: fixed; /* important */
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 99999;
            background: #fff;
            padding: 10px;
            border-radius: 10px;
            box-shadow: 0 0 25px rgba(0,0,0,.4);
        }

            .image-popup img {
                max-width: 600px;
                max-height: 500px;
                width: auto;
                height: auto;
            }

        .image-hover-container:hover .image-popup {
            display: block;
        }
        /*END*/
    </style>
    <script type="text/javascript">
        function updateStatus(element) {
            var userId = element.getAttribute("data-id");
            var value = element.checked;

            $.ajax({
                type: "POST",
                url: "ProductList.aspx/UpdateUserSetting",
                data: JSON.stringify({
                    id: userId,
                    val: value
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    //console.log("Updated Successfully");
                    window.location.reload();
                },
                error: function (error) {
                    //console.log(error);
                }
            });

        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Product List</b></h3>
                    <asp:Button ID="btnCreate" CssClass="btn btn-outline-primary" Font-Bold="true" Text="Create" CausesValidation="false" OnClick="btnCreate_Click" runat="server" />
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Search:</asp:Label>
                            <asp:TextBox ID="txtproductname" CssClass="form-control" runat="server" Width="100%" OnTextChanged="txtproductname_TextChanged" AutoPostBack="true"></asp:TextBox>
                            <%-- <asp:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" CompletionListCssClass="completionList"
                                CompletionListHighlightedItemCssClass="itemHighlighted" CompletionListItemCssClass="listItem"
                                CompletionInterval="10" MinimumPrefixLength="1" ServiceMethod="GetCompanyList"
                                TargetControlID="txtproductname" Enabled="true">
                            </asp:AutoCompleteExtender>--%>
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
                        <asp:GridView ID="GVDetails" runat="server" DataKeyNames="ID" OnRowDataBound="GVDetails_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVDetails_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Product Code" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblProduct" runat="server" Text='<%#Eval("Productcode")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Product Name" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblProductname" runat="server" Text='<%#Eval("Productname")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Size" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSize" runat="server" Text='<%#Eval("Size")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Image" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <div class="image-hover-container">
                                            <asp:Image ID="imG" runat="server"
                                                ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("ImagenamePath"))) 
                                                  ? Convert.ToString(Eval("ImagenamePath")).Replace("~/", "/Content/") 
                                                  : "https://placehold.co/100x100?text=Image" %>'
                                                CssClass="product-image-preview" />

                                            <div class="image-popup">
                                                <asp:Image ID="imgLarge" runat="server"
                                                    ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("ImagenamePath"))) 
                                                      ? Convert.ToString(Eval("ImagenamePath")).Replace("~/", "/Content/") 
                                                      : "https://placehold.co/400x400?text=Image" %>' />
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Activate" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <label class="switch">
                                            <input type="checkbox" class="ipCheckToggle" data-id='<%# Eval("ID") %>' onchange="updateStatus(this)"
                                                <%# (Eval("IsActive") != DBNull.Value && Convert.ToBoolean(Eval("IsActive"))) ? "checked='checked'" : "" %> />
                                            <span class="slider round"></span>
                                        </label>
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


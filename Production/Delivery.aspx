<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="Delivery.aspx.cs" Inherits="Delivery" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
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
        $("[src*=add-black]").live("click", function () {
            $(this).closest("tr").after("<tr><td colspan = '999'>" + $(this).next().html() + "</td></tr>")
            $(this).attr("src", "/Content/assets/images/newminus.png");
        });
        $("[src*=newminus]").live("click", function () {
            $(this).attr("src", "/Content/assets/images/add-black.png");
            $(this).closest("tr").next().remove();
        });

        function ToggleConfirmButton() {

            var file = document.getElementById("<%= fuLRCopy.ClientID %>");
            var btn = document.getElementById("<%= btnConfirmDelivery.ClientID %>");

            btn.disabled = (file.value == "");
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Delivery List</b></h3>
                </div>
                <div class="card-body">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <asp:Label ID="Label1" runat="server" Font-Bold="true" CssClass="form-label">Search:</asp:Label>
                            <asp:TextBox ID="txtcompanyname" CssClass="form-control" runat="server" Width="100%" OnTextChanged="txtCustomerName_TextChanged" AutoPostBack="true"></asp:TextBox>
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
                        <asp:GridView ID="GVCompany" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false" OnRowCommand="GVCompany_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText=" " ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <img alt="" style="cursor: pointer; width: 26px;" src="/Content/assets/images/add-black.png" />
                                        <asp:Panel ID="pnlOrders" runat="server" Style="display: none">
                                            <asp:GridView ID="gvDetails" runat="server" HeaderStyle-HorizontalAlign="Center" CssClass="display table table-striped table-hover" AutoGenerateColumns="false">
                                                <HeaderStyle BackColor="#7f9abb" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblsnos" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="ProductName" HeaderText="Product Name" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Description" HeaderText="Description" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Size" HeaderText="Size" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Unit" HeaderText="Unit" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Qty" HeaderText="Qty" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="SqFeet" HeaderText="Sq Feet" />
                                                    <asp:TemplateField HeaderText="Custom Image" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <div class="image-hover-container">
                                                                <asp:Image ID="imG" runat="server"
                                                                    ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("UploadedImage"))) 
                                                                ? Convert.ToString(Eval("UploadedImage")).Replace("~/", "/Content/") 
                                                                : "https://placehold.co/100x100?text=Image" %>'
                                                                    CssClass="product-image-preview" />

                                                                <div class="image-popup">
                                                                    <asp:Image ID="imgLarge" runat="server"
                                                                        ImageUrl='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("UploadedImage"))) 
                                                                    ? Convert.ToString(Eval("UploadedImage")).Replace("~/", "/Content/") 
                                                                    : "https://placehold.co/400x400?text=Image" %>' />
                                                                </div>
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:Panel>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblsno" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tally Ref No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTallyRefNo" runat="server" ForeColor="Red" Font-Bold="true" Text='<%#Eval("TallyRefNo")%>'></asp:Label>
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
                                <asp:TemplateField HeaderText="WorkOrder Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderDate" runat="server" Text='<%#Eval("WorkOrderDate")%>'></asp:Label>
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
                                <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="160px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lblVal" runat="server" Enabled='<%# Eval("IsAllCompleted").ToString() == "True" ? false:true %>'
                                            Visible='<%# string.IsNullOrWhiteSpace(Eval("IsAllCompleted").ToString()) ? true : true %>'
                                            Text='<%#
                                                    Eval("IsAllCompleted").ToString() == "True" ? "Delivered" :
                                                    Eval("IsDispatched").ToString() == "True" ? "Dispatched" :
                                                    Eval("IsProductionCompleted").ToString() == "True" ? "Ready to Dispatch" :
                                                    ""
                                                %>'
                                            ForeColor='<%#
                                                    Eval("IsAllCompleted").ToString() == "True" ? System.Drawing.ColorTranslator.FromHtml("#0f5df1") :
                                                    Eval("IsDispatched").ToString() == "True" ? System.Drawing.Color.Green :
                                                    Eval("IsProductionCompleted").ToString() == "True" ? System.Drawing.Color.Red :
                                                    System.Drawing.Color.Black
                                                %>'
                                            Font-Bold="true"
                                            CommandName="UpdateStatus"
                                            CommandArgument='<%# Eval("ID") + "," + Eval("IsProductionCompleted") + "," + Eval("IsDispatched") %>'>
                                       </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <div class="modal fade" id="deliveryModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content" style="background: #313438;">

                        <div class="modal-header">
                            <h5 class="modal-title" style="color: whitesmoke">Complete Delivery</h5>
                        </div>

                        <div class="modal-body">

                            <asp:HiddenField ID="hfOrderId" runat="server" />

                            <div class="mb-3">
                                <label style="color: whitesmoke">LR Copy<span style="color: red">*</span></label>
                                <asp:FileUpload ID="fuLRCopy" runat="server" CssClass="form-control" onchange="ToggleConfirmButton();" />
                            </div>

                            <div class="mb-3">
                                <label style="color: whitesmoke">Remark<span style="color: red">*</span></label>
                                <asp:TextBox ID="txtRemark" runat="server"
                                    CssClass="form-control"
                                    TextMode="MultiLine"
                                    Rows="3" Style="background: transparent; color: whitesmoke;"></asp:TextBox>
                                <asp:RequiredFieldValidator
                                    ID="rfvRemark"
                                    runat="server"
                                    ControlToValidate="txtRemark"
                                    ErrorMessage="Remark is required."
                                    ForeColor="Red"
                                    Display="Dynamic"
                                    ValidationGroup="Delivery">
                                </asp:RequiredFieldValidator>
                            </div>

                        </div>

                        <div class="modal-footer">
                            <asp:Button ID="btnConfirmDelivery"
                                runat="server"
                                Text="Confirm"
                                Enabled="false"
                                CssClass="btn btn-primary"
                                ValidationGroup="Delivery"
                                OnClick="btnConfirmDelivery_Click" />
                        </div>

                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnConfirmDelivery" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignWorkOrder1.aspx.cs" Inherits="AssignWorkOrder1" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript">
       
        // ─── expand / collapse ───────────────────────────────────────────
        $(document).on("click", "[src*='add-black']", function () {
            $(this).closest("tr").after(
                "<tr class='detail-row'><td colspan='999'>" +
                $(this).next().html() +
                "</td></tr>"
            );
            $(this).attr("src", "/Content/assets/images/newminus.png");
        });

        $(document).on("click", "[src*='newminus']", function () {
            $(this).attr("src", "/Content/assets/images/add-black.png");
            $(this).closest("tr").next(".detail-row").remove();
        });

        var selectedMachineCapacity = 0;
        var remainingCapacity = 0;

        function SelectSingleMachine(chk) {

            $("#gvStageCapacity input[type=checkbox]").not(chk).prop("checked", false);

            if (chk.checked) {

                var row = $(chk).closest("tr");

                selectedMachineCapacity =
                    parseFloat(row.find("td:eq(5)").text()) || 0; // MachineAvailable

                remainingCapacity = selectedMachineCapacity;

                $("#spnCapacityStatus").html(
                    "0 / " + selectedMachineCapacity
                );

                redistributeCapacity();
            }
            else {
                selectedMachineCapacity = 0;
                remainingCapacity = 0;
            }
        }

        function ToggleWO(chk) {

            if (selectedMachineCapacity <= 0) {
                alert("Please select machine first.");
                chk.checked = false;
                return false;
            }

            var checkedRows =
                $("#GVCompany input[id*='chkSend']:checked");

            if (!chk.checked)
                redistributeCapacity();
            else {

                if (remainingCapacity <= 0) {
                    alert("Machine capacity exhausted.");
                    chk.checked = false;
                    return false;
                }

                redistributeCapacity();
            }

            return true;
        }

        function redistributeCapacity() {

            var checkedRows =
                $("#GVCompany input[id*='chkSend']:checked");

            var count = checkedRows.length;

            if (count == 0)
                return;

            var capacityPerWO =
                selectedMachineCapacity / count;

            checkedRows.each(function () {

                var woRow = $(this).closest("tr");

                distributeWO(
                    woRow,
                    capacityPerWO
                );
            });

            updateCapacitySummary();
        }

        function distributeWO(woRow, allocatedSqFeet) {

            var detailsGrid =
                woRow.next(".detail-row")
                    .find("table");

            detailsGrid.find("tr").each(function () {

                var qtyCell =
                    $(this).find("td:eq(6)");

                var sqFeetCell =
                    $(this).find("td:eq(5)");

                var lblQty =
                    $(this).find(".UsedQty");

                var lblSqFeet =
                    $(this).find(".UsedSqFeet");

                if (sqFeetCell.length == 0)
                    return;

                var itemSqFeet =
                    parseFloat(sqFeetCell.text()) || 0;

                if (itemSqFeet == 0)
                    return;

                var qty =
                    Math.floor(
                        allocatedSqFeet / itemSqFeet
                    );

                lblQty.text(qty);
                lblSqFeet.text(qty * itemSqFeet);
            });

            updateBalanceQty(woRow);
        }

        function changeQty(btn, increment) {

            var row = $(btn).closest("tr");

            var qtyLabel =
                row.find(".UsedQty");

            var sqFeetLabel =
                row.find(".UsedSqFeet");

            var qty =
                parseInt(qtyLabel.text()) || 0;

            var itemSqFeet =
                parseFloat(
                    row.find("td:eq(5)").text()
                ) || 0;

            if (increment > 0) {

                if (remainingCapacity < itemSqFeet) {
                    alert("No machine capacity available.");
                    return;
                }

                qty++;

                remainingCapacity -= itemSqFeet;
            }
            else {

                if (qty == 0)
                    return;

                qty--;

                remainingCapacity += itemSqFeet;
            }

            qtyLabel.text(qty);
            sqFeetLabel.text(qty * itemSqFeet);

            updateCapacitySummary();

            var woRow =
                $(btn).closest(".detail-row")
                    .prev("tr");

            updateBalanceQty(woRow);
        }

        function updateBalanceQty(woRow) {

            var totalQty =
                parseInt(
                    woRow.find("[id*=lblQty]").text()
                ) || 0;

            var usedQty = 0;

            var detailGrid =
                woRow.next(".detail-row")
                    .find("table");

            detailGrid.find(".UsedQty").each(function () {

                usedQty +=
                    parseInt($(this).text()) || 0;
            });

            woRow.find(".balanceQty")
                .text(totalQty - usedQty);
        }

        function updateCapacitySummary() {

            var used = 0;

            $(".UsedSqFeet").each(function () {

                used +=
                    parseFloat($(this).text()) || 0;
            });

            remainingCapacity =
                selectedMachineCapacity - used;

            $("#spnCapacityStatus")
                .html(
                    used +
                    " / " +
                    selectedMachineCapacity
                );

            if (remainingCapacity < 0)
                remainingCapacity = 0;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="card">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h3 class="m-0 font-weight-bold"><b>Start Production</b></h3>
                </div>
                <div class="card-body">
                    <div class="row table-responsive">
                        <center>
                            <h3 style="color: #eb7025; font-weight: 900;">Machine Capacity</h3>
                        </center>
                        <asp:GridView ID="gvStageCapacity" ClientIDMode="Static" runat="server" HeaderStyle-BackColor="#5b78b1"
                            CssClass="table table-bordered table-sm table-hover text-center"
                            AutoGenerateColumns="False">
                            <Columns>
                                <asp:TemplateField HeaderText="#" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="20">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkMachine" runat="server" onclick="SelectSingleMachine(this);" />
                                        <asp:Label ID="lblMachineID" runat="server" CssClass="d-none" Text='<%# Eval("MachineID")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Stage">
                                    <ItemTemplate>
                                        <span class="badge bg-info">
                                            <%# Eval("AllocatedStage") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="MachineName" HeaderText="Machine Name" />
                                <asp:BoundField DataField="MachineCapacity" HeaderText="Sq Feet" />
                                <asp:BoundField DataField="MachineLoad" HeaderText="Active Load" />
                                <asp:BoundField DataField="MachineAvailable" HeaderText="Available Sq Feet" />
                                <asp:TemplateField HeaderText="Load %">
                                    <ItemTemplate>
                                        <span class="badge 
                                      <%# Convert.ToDecimal(Eval("LoadPercentage")) >= 100 ? "bg-danger" :
                                          Convert.ToDecimal(Eval("LoadPercentage")) >= 70 ? "bg-warning" : "bg-success" %>">
                                            <%# Eval("LoadPercentage") %> %
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <hr />
                    <div class="py-3 d-flex flex-row align-items-center justify-content-between">
                        <h3 class="m-0 font-weight-bold" style="color: #eb7025; font-weight: 900;">Allocate Machine</h3>
                        <span style="font-weight: 900;">Total Capacity : <span id="spnCapacityStatus" style="font-weight: bold; font-size: 16px; color: green;">0 / 0</span></span>
                        <asp:Button ID="btnCreate" CssClass="btn btn-outline-primary" Font-Bold="true" Text="Multiple Send" CausesValidation="false" runat="server" OnClick="btnCreate_Click" />
                    </div>
                    <div class="row table-responsive">
                        <div class="row">
                            <div class="col-md-3">
                                <asp:TextBox ID="txtdate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                        <br />
                        <asp:GridView ID="GVCompany" ClientIDMode="Static" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false">
                            <Columns>
                                <asp:TemplateField HeaderText="#" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="20">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSend" runat="server" onclick="return ToggleWO(this);"  Enabled='<%#Eval("WOStatus").ToString() != "Pending" ? false : true %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText=" " ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <img alt="" style="cursor: pointer; width: 26px;" src="/Content/assets/images/add-black.png" />
                                        <asp:Panel ID="pnlOrders" runat="server" Style="display: none">
                                            <asp:GridView ID="Gvdetails" runat="server" HeaderStyle-HorizontalAlign="Center" CssClass="display table table-striped table-hover" AutoGenerateColumns="false">
                                                <HeaderStyle BackColor="#7f9abb" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Sr.No." ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblsnos" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="ProductName" HeaderText="Product Name" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="PartNo" HeaderText="Item Code" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Description" HeaderText="Description" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Size" HeaderText="Size" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="SqFeet" HeaderText="Sq Feet" />
                                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" DataField="Qty" HeaderText="Qty" />
                                                    <asp:TemplateField HeaderText="Used Qty" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <button type="button" class="btnMinus" onclick="changeQty(this,-1)">-</button>

                                                            <asp:Label ID="lblUsedQty" runat="server"
                                                                CssClass="UsedQty" Text="0"></asp:Label>

                                                            <button type="button" class="btnPlus" onclick="changeQty(this,1)">+</button>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Used Sq Feet" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblUsedSqFeet" runat="server" CssClass="UsedSqFeet" Text="0"></asp:Label>
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
                                <asp:TemplateField HeaderText="WorkOrder No" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="180">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDealer" runat="server" Text='<%#Eval("WorkOrderNo")%>'></asp:Label>
                                        <asp:Label ID="lblWoID" CssClass="d-none" runat="server" Text='<%#Eval("ID")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WorkOrder Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWorkOrderDate" runat="server" Text='<%#Eval("WorkOrderDate")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="SqFeet" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSqFeet" runat="server" Text='<%#Eval("SqFeet")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Total Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" runat="server" Text='<%#Eval("Qty")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Balance Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblBalanceQty" runat="server" CssClass="balanceQty" Text="0"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="WO Status" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWOStatus" runat="server" Text='<%#Eval("WOStatus")%>'
                                            ForeColor='<%#Eval("WOStatus").ToString() =="Pending"? System.Drawing.Color.Red : System.Drawing.Color.Green %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Send Qty" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="d-none" ItemStyle-CssClass="d-none" HeaderStyle-Width="60">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSendQty" runat="server" CssClass="form-control" onfocus="CheckMachineSelected(this)" onkeypress="return event.charCode >= 48 && event.charCode <= 57" onkeyup="UpdateCapacityStatus()" onblur="validateQty(this)"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="d-none" ItemStyle-CssClass="d-none">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSend" runat="server" CssClass="btn btn-outline-primary" Text="Send" OnClientClick="return ValidateSendQty(this);" OnClick="btnSend_Click"></asp:LinkButton>
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

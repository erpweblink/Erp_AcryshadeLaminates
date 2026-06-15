<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignWorkOrder.aspx.cs" Inherits="AssignWorkOrder" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript">
        var selectedMachineCapacity = 0;

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

        // ─── machine selection (radio-style) ─────────────────────────────
        function SelectSingleMachine(chk) {
            $("#gvStageCapacity input[type='checkbox']")
                .not(chk).prop("checked", false);

            if ($(chk).prop("checked")) {
                var row = $(chk).closest("tr");
                selectedMachineCapacity =
                    parseFloat($(row).find("td:eq(3)").text().trim()) || 0;
            } else {
                selectedMachineCapacity = 0;
            }

            RecalculateAllAllocations();
        }

        // ─── validate before allowing WO checkbox ────────────────────────
        function ValidateCapacity(chk) {
            if (selectedMachineCapacity <= 0) {
                alert("Please select a machine first.");
                chk.checked = false;
                return false;
            }
            setTimeout(RecalculateAllAllocations, 0);
            return true;
        }

        // ─── helper: get only data rows (no header) from a detail table ──
        function getDetailRows(woRow) {
            // First check inside the row itself (hidden panel, not yet expanded)
            var inRow = woRow.find("table[id*='Gvdetails'] tr");
            // Then check the next .detail-row sibling (after expand/clone)
            var inSibling = woRow.next(".detail-row").find("table tr");

            var rows = inRow.length ? inRow : inSibling;

            // Return only rows that have <td> direct children (skip header <th> rows)
            return rows.filter(function () {
                return $(this).children("td").length > 0;
            });
        }

        // ─── read a numeric value safely from a cell ─────────────────────
        function cellNum(cells, idx) {
            var cell = cells.eq(idx);
            // Try direct text first, then any child element text
            var txt = cell.children("span,label").text().trim();
            if (!txt) txt = cell.text().trim();
            return parseFloat(txt) || 0;
        }

        // ─── core recalculation ──────────────────────────────────────────
        function RecalculateAllAllocations() {
            $(".UsedQty").text("0");
            $(".UsedSqFeet").text("0");
            $(".balanceQty").text("0");

            var remainingCapacity = selectedMachineCapacity;

            $("#GVCompany tr").each(function () {
                var woRow = $(this);
                var chk = woRow.find("input[type='checkbox'][id*='chkSend']");

                if (!chk.length || !chk.prop("checked")) return;

                var detailRows = getDetailRows(woRow);
                if (!detailRows.length) return;

                var totalQty = 0;
                var totalUsedQty = 0;

                detailRows.each(function () {
                    var cells = $(this).children("td");
                    if (cells.length === 0) return;

                    var itemSqFt = cellNum(cells, 5);
                    var itemQty = cellNum(cells, 6);
                    totalQty += itemQty;

                    var allocated = 0;
                    if (remainingCapacity > 0 && itemSqFt > 0) {
                        allocated = Math.min(itemSqFt, remainingCapacity);
                        remainingCapacity -= allocated;
                    }

                    var usedQty = 0;
                    if (itemSqFt > 0) {
                        usedQty = Math.floor((allocated / itemSqFt) * itemQty);
                    }

                    $(this).find(".UsedQty").text(usedQty);
                    $(this).find(".UsedSqFeet").text(allocated);
                    totalUsedQty += usedQty;
                });

                woRow.find(".balanceQty").text(totalQty - totalUsedQty);
            });

            var usedCapacity = selectedMachineCapacity - remainingCapacity;
            $("#spnCapacityStatus").text(usedCapacity + " / " + selectedMachineCapacity);
        }

        // ─── manual +/- qty adjustment ───────────────────────────────────
        function changeQty(btn, change) {
            var row = $(btn).closest("tr");
            var cells = row.children("td");      // direct children ONLY

            if (cells.length === 0) return false;

            var qtyCell = row.find(".UsedQty");
            var sqFeetCell = row.find(".UsedSqFeet");

            // Use the safe cellNum helper to read SqFeet and Qty
            var totalItemSqFt = cellNum(cells, 5);
            var totalItemQty = cellNum(cells, 6);

            // Debug fallback: log to console so you can verify
            // console.log("SqFt:", totalItemSqFt, "Qty:", totalItemQty);

            var currentQty = parseFloat(qtyCell.text().trim()) || 0;
            var newQty = currentQty + change;

            // Boundary checks
            if (newQty < 0) {
                return false;
            }
            if (totalItemQty > 0 && newQty > totalItemQty) {
                alert("Cannot exceed total quantity of " + totalItemQty);
                return false;
            }

            var sqFtPerQty = totalItemQty > 0 ? totalItemSqFt / totalItemQty : 0;
            var newUsedSqFt = Math.round(newQty * sqFtPerQty * 100) / 100;

            // Total capacity check
            var currentCapacityUsed = 0;
            $(".UsedSqFeet").each(function () {
                currentCapacityUsed += parseFloat($(this).text()) || 0;
            });

            var revisedCapacity = currentCapacityUsed
                - (parseFloat(sqFeetCell.text()) || 0)
                + newUsedSqFt;

            if (change > 0 && revisedCapacity > selectedMachineCapacity) {
                alert("Machine capacity exceeded. Available: " +
                    (selectedMachineCapacity - currentCapacityUsed +
                        (parseFloat(sqFeetCell.text()) || 0)).toFixed(2) + " sq ft");
                return false;
            }

            qtyCell.text(newQty);
            sqFeetCell.text(newUsedSqFt);
            updateBalanceQty();

            $("#spnCapacityStatus").text(
                revisedCapacity.toFixed(2) + " / " + selectedMachineCapacity
            );

            return true;
        }

        // ─── recalculate balance qty column only ─────────────────────────
        function updateBalanceQty() {
            $("#GVCompany tr").each(function () {
                var woRow = $(this);
                var detailRows = getDetailRows(woRow);
                if (!detailRows.length) return;

                var totalQty = 0, usedQty = 0;
                detailRows.each(function () {
                    var cells = $(this).children("td");
                    if (!cells.length) return;
                    totalQty += cellNum(cells, 6);
                    usedQty += parseFloat($(this).find(".UsedQty").text()) || 0;
                });

                woRow.find(".balanceQty").text(totalQty - usedQty);
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
                            <div class="col-md-4">
                                <asp:TextBox ID="txtdate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                        <br />
                        <asp:GridView ID="GVCompany" ClientIDMode="Static" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false">
                            <Columns>
                                <asp:TemplateField HeaderText="#" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="20">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSend" runat="server" onclick="return ValidateCapacity(this);" Enabled='<%#Eval("WOStatus").ToString() != "Pending" ? false : true %>' />
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

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignWorkOrder.aspx.cs" Inherits="AssignWorkOrder" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        window.onload = function () {
            UpdateCapacityStatus();
            document.querySelectorAll(".priority-ddl").forEach(function (ddl) {
                setPriorityColor(ddl);
            });
        };

        function PriorityChanged(ddl, id) {

            setPriorityColor(ddl);

            var priority = ddl.value;

            // Call AJAX to update database
            UpdatePriority(id, priority);
        }

        function UpdatePriority(id, priority) {

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/UpdatePriority",
                data: JSON.stringify({
                    id: id,
                    priority: priority
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Priority updated");
                },
                error: function (xhr) {
                    alert("Error updating priority");
                }
            });
        }

        function setPriorityColor(ddl) {

            ddl.style.color = "black";

            switch (ddl.value) {
                case "Urgent":
                    ddl.style.backgroundColor = "#dc3545"; // Red
                    ddl.style.color = "white";
                    break;

                case "Fast":
                    ddl.style.backgroundColor = "#198754"; // Green
                    ddl.style.color = "white";
                    break;

                case "Slow":
                    ddl.style.backgroundColor = "#ffc107"; // Yellow
                    ddl.style.color = "black";
                    break;

                default:
                    ddl.style.backgroundColor = "";
                    ddl.style.color = "";
                    break;
            }
        }

        function SelectSingleMachine(chk) {

            var grid = document.getElementById("gvStageCapacity");

            var checkboxes = grid.querySelectorAll("input[type='checkbox']");

            // Allow only one machine selection
            for (var i = 0; i < checkboxes.length; i++) {

                if (checkboxes[i] != chk)
                    checkboxes[i].checked = false;
            }

            var availableCapacity = GetStage1Capacity();
            var selectedQty = GetSelectedQty();

            if (selectedQty > availableCapacity) {

                alert(
                    "Selected WorkOrder Qty (" + selectedQty +
                    ") exceeds the newly selected machine capacity (" +
                    availableCapacity +
                    "). All selected rows will be unchecked."
                );

                UncheckAllWorkOrders();
            }

            UpdateCapacityStatus();
        }

        function UncheckAllWorkOrders() {

            var companyGrid = document.getElementById("GVCompany");

            for (var i = 1; i < companyGrid.rows.length; i++) {

                var row = companyGrid.rows[i];

                var chk = row.cells[0].getElementsByTagName("input")[0];

                if (chk)
                    chk.checked = false;
            }
        }

        function ValidateCapacity(chk) {

            var availableCapacity = GetStage1Capacity();

            if (availableCapacity == 0) {

                alert("Please select a machine first.");

                chk.checked = false;
                return false;
            }

            var totalQty = GetSelectedQty();

            if (totalQty > availableCapacity) {

                alert("Selected Qty (" + totalQty +
                    ") exceeds available machine capacity (" +
                    availableCapacity + ").");

                chk.checked = false;

                UpdateCapacityStatus();

                return false;
            }

            UpdateCapacityStatus();
            return true;
        }

        function GetStage1Capacity() {

            var stageGrid = document.getElementById("gvStageCapacity");

            for (var i = 1; i < stageGrid.rows.length; i++) {

                var chk = stageGrid.rows[i]
                    .cells[0]
                    .getElementsByTagName("input")[0];

                if (chk.checked) {

                    return parseFloat(stageGrid.rows[i].cells[5].innerText) || 0;
                    // Column 5 = Available Capacity
                }
            }

            return 0;
        }

        function GetSelectedQty() {

            var totalQty = 0;

            var companyGrid = document.getElementById("GVCompany");

            for (var i = 1; i < companyGrid.rows.length; i++) {

                var row = companyGrid.rows[i];

                var checkbox = row.querySelector("input[id*='chkSend']");
                var btnSend = row.querySelector("a[id*='btnSend']");

                // Total Qty column
                var qty = parseFloat(row.cells[5].innerText) || 0;

                // Send Qty textbox
                var txtSendQty = row.querySelector("input[id*='txtSendQty']");
                var sendQty = parseFloat(txtSendQty.value) || 0;

                // If checkbox selected use full qty
                if (checkbox.checked) {
                    totalQty += qty;
                    btnSend.style.display = "none";
                }
                // Otherwise use entered send qty
                else if (sendQty > 0) {
                    totalQty += sendQty;

                } else {
                    btnSend.style.display = "inline-block";
                }
            }

            return totalQty;
        }

        function UpdateCapacityStatus() {

            var availableCapacity = GetStage1Capacity();

            var totalQty = GetSelectedQty();

            var span = document.getElementById("spnCapacityStatus");

            span.innerHTML = totalQty + " / " + availableCapacity;

            var percentage = 0;

            if (availableCapacity > 0)
                percentage = (totalQty / availableCapacity) * 100;

            if (percentage >= 100) {
                span.style.color = "red";
            }
            else if (percentage >= 80) {
                span.style.color = "orange";
            }
            else {
                span.style.color = "green";
            }
        }

        function GetRemainingCapacity() {

            var totalCapacity = GetStage1Capacity(); // 192

            var usedCapacity = GetSelectedQty();     // 100

            return totalCapacity - usedCapacity;     // 92
        }

        function validateQty(txt) {

            var row = txt.closest("tr");

            var totalQty = parseFloat(
                row.querySelector("[id*='lblQty']").innerText
            ) || 0;

            var sendQty = parseFloat(txt.value) || 0;

            if (sendQty > totalQty) {

                alert("Send Qty cannot be greater than Total Qty (" + totalQty + ")");

                txt.value = "";

                UpdateCapacityStatus();

                return false;
            }

            var availableCapacity = GetStage1Capacity();

            var usedQty = GetSelectedQty();

            if (usedQty > availableCapacity) {

                alert("Selected Qty (" + usedQty +
                    ") exceeds machine capacity (" +
                    availableCapacity + ").");

                txt.value = "";

                UpdateCapacityStatus();

                return false;
            }

            UpdateCapacityStatus();

            return true;
        }

        function IsMachineSelected() {

            var stageGrid = document.getElementById("gvStageCapacity");

            for (var i = 1; i < stageGrid.rows.length; i++) {

                var chk = stageGrid.rows[i]
                    .cells[0]
                    .getElementsByTagName("input")[0];

                if (chk.checked)
                    return true;
            }

            return false;
        }

        function CheckMachineSelected(txt) {

            if (!IsMachineSelected()) {

                alert("Please select a machine first.");

                txt.value = "";
                txt.blur();

                return false;
            }

            return true;
        }

        function ValidateSendQty(btn) {
            var row = btn.closest("tr"); // Get the row of the clicked button
            var txtSendQty = row.querySelector("input[id*='txtSendQty']");
            var qty = parseFloat(txtSendQty.value) || 0;

            if (qty <= 0) {
                alert("Please enter a valid Send Qty greater than 0.");
                txtSendQty.focus();
                return false; // Cancel postback
            }

            // Optional: also check machine capacity
            var availableCapacity = GetStage1Capacity();
            var totalQty = GetSelectedQty(); // includes Send Qty

            if (totalQty > availableCapacity) {
                alert("Selected Qty exceeds available machine capacity (" + availableCapacity + ").");
                return false; // Cancel postback
            }

            return true; // Allow postback
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
                                <asp:BoundField DataField="MachineCapacity" HeaderText="Capacity" />
                                <asp:BoundField DataField="MachineLoad" HeaderText="Active Load" />
                                <asp:BoundField DataField="MachineAvailable" HeaderText="Available Capacity" />
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
                        <asp:GridView ID="GVCompany" ClientIDMode="Static" runat="server" DataKeyNames="ID" OnRowDataBound="GVCompany_RowDataBound" CssClass="table table-bordered table-striped" HeaderStyle-BackColor="#5b78b1"
                            HeaderStyle-Font-Bold="true" HeaderStyle-ForeColor="Black" HeaderStyle-HorizontalAlign="Center" AutoGenerateColumns="false">
                            <Columns>
                                <asp:TemplateField HeaderText="Priority" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="155">
                                    <ItemTemplate>
                                        <asp:DropDownList ID="ddlPriority" runat="server" Font-Bold="true" CssClass="form-control priority-ddl" onchange='<%# "PriorityChanged(this," + Eval("ID") + ")" %>'>
                                            <asp:ListItem Value="">--Set Priority--</asp:ListItem>
                                            <asp:ListItem Value="Slow">Slow</asp:ListItem>
                                            <asp:ListItem Value="Fast">Fast</asp:ListItem>
                                            <asp:ListItem Value="Urgent">Urgent</asp:ListItem>
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="#" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="20">
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSend" runat="server" onclick="return ValidateCapacity(this);" Enabled='<%#Eval("WOStatus").ToString() != "Pending" ? false : true %>' />
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
                                <asp:TemplateField HeaderText="Product Count" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblProductCount" runat="server" Text='<%#Eval("ProductCount")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Total Qty" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" runat="server" Text='<%#Eval("Qty")%>'></asp:Label>
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

<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="WoProductionS1.aspx.cs" Inherits="WoProductionS1" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <style type="text/css">
        /* ================= TABLE BASE STYLE (MATCH GRIDVIEW) ================= */
        table {
            width: 100%;
            border-collapse: collapse;
        }

            /* HEADER STYLE (same as HeaderStyle-BackColor="#5b78b1") */
            table tr:first-child th {
                background: #5b78b1;
                color: black;
                font-weight: bold;
                text-align: center;
                padding: 10px;
                border: 1px solid #ddd;
            }

            /* CELL STYLE */
            table td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: center;
                vertical-align: middle;
            }

            /* HOVER LIKE Bootstrap table-hover */
            table tr:hover {
                background: #f5f5f5;
            }

        /* MACHINE BADGE STYLE */
        .badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-weight: bold;
            color: white;
        }

        .bg-info {
            background: #17a2b8;
        }

        .bg-danger {
            background: #dc3545;
        }

        .bg-warning {
            background: #ffc107;
            color: black;
        }

        .bg-success {
            background: #28a745;
        }

        /* BUTTON STYLE LIKE bootstrap-outline-primary */
        button {
            padding: 3px 8px;
            margin: 2px;
            cursor: pointer;
            border: 1px solid #007bff;
            background: transparent;
            color: #007bff;
            border-radius: 3px;
            font-size: 15px;
        }

            button:hover {
                background: #007bff;
                color: white;
            }

        /* REMOVE BUTTON BORDER FOR + / - SMALL */
        .btnMinus, .btnPlus {
            width: 24px;
            height: 24px;
            padding: 0;
            line-height: 20px;
        }

        /* INPUT STYLE LIKE ASP.NET */
        input[type="checkbox"], input[type="radio"] {
            transform: scale(1.1);
        }

        /* CARD HEADER STYLE MATCH */
        h3 {
            font-weight: 700;
        }

        /* DETAIL ROW BACKGROUND */
        .detail-row td {
            background: #fafafa;
        }
    </style>
    <script type="text/javascript">
        var AssignWorkOrders = [];
        var operatorData = [];
        var qtyUpdating = {};
        $(function () {
            loadOperatorDetails();
        });

        function loadMachine() {
            $.ajax({
                type: "POST",
                url: "WoProductionS1.aspx/GetMachines",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = JSON.parse(response.d);
                    var ddl = $("#ddlMachine");

                    ddl.empty();
                    ddl.append("<option value=''>-Select Machine-</option>");

                    $.each(rows, function (i, machine) {
                        ddl.append(
                            "<option value='" + machine.ID + "'>" +
                            machine.MachineName +
                            "</option>"
                        );
                    });
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Machine data");
                }
            });
        }

        function loadOperatorDetails() {
            $.ajax({
                type: "POST",
                url: "WoProductionS1.aspx/GetOperatorDetails",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var role = response.d.Role;
                    operatorData = JSON.parse(response.d.Data);

                    $("#ddlMachine").empty();
                    if (role === "Operator") {

                        if (operatorData.length > 0) {
                            currentMachineId = operatorData[0].MachineID;

                            $("#ddlMachine").append(
                                "<option value='" + currentMachineId + "' selected>" +
                                operatorData[0].MachineName +
                                "</option>"
                            );

                            $("#ddlMachine").prop("disabled", true);


                            machineChanged(currentMachineId);
                        }

                    } else {
                        $("#ddlMachine").prop("disabled", false);
                        loadMachine(); // admin full list
                    }
                }
            });
        }

        function machineChanged(machineId) {

            machineId = machineId || $("#ddlMachine").val();

            if (!machineId) {
                window.location.href = window.location.href;
                return;
            }


            currentMachineId = machineId;

            // show operator info
            var operator = operatorData.find(x => x.MachineID == machineId);

            if (operator) {
                var html = `
                <div class="row mb-3">
                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Operator</b><br/>
                            ${operator.OperatorName}
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Target Qty</b><br/>
                            ${operator.TargetQty}
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card p-2">
                            <b>Completed Qty</b><br/>
                            ${operator.CompletedQty}
                        </div>
                    </div>
                </div>`;
                $("#operatorInfo").html(html).show();
            }

            // 🔥 LOAD WORK ORDERS FOR SELECTED MACHINE
            loadWorkOrder(machineId);
        }

        function loadWorkOrder(machineId) {
            $.ajax({
                type: "POST",
                url: "WoProductionS1.aspx/GetAssignWorkOrders",
                data: JSON.stringify({ machineId: machineId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var rows = JSON.parse(response.d);
                    AssignWorkOrders = [];
                    var grouped = {};
                    debugger;
                    $.each(rows, function (i, row) {
                        if (!grouped[row.ProductionID]) {
                            grouped[row.ProductionID] = {
                                woId: row.ProductionID,
                                rankNo: parseInt(row.RankNo),
                                woNo: row.WorkOrderNo,
                                scheduledDate: row.ScheduledDate || '',
                                customer: row.Dealer,
                                totalSqFeet: 0,
                                totalQty: 0,
                                AllocatedQty: 0,
                                RevertQty: 0,
                                balanceQty: 0,
                                status: row.Status1 || "Machine Not Allocated",
                                details: [],
                                isCompleted: true
                            };
                        }
                        grouped[row.ProductionID].details.push({
                            detailedId: row.DetailedID,
                            product: row.ProductName,
                            size: row.Size,

                            originalQty: parseFloat(row.totQty),
                            originalsqFeet: parseFloat(row.SqFeet || 0),

                            allocatedQty: parseFloat(row.AllocatedQty || 0),
                            allocatedSqFeet: parseFloat(row.AllocatedSqFeet || 0),

                            usedQty: parseFloat(row.CompletedQty || 0),
                            usedSqFt: parseFloat(row.CompetedSqFeet || 0),
                            stage1compDate: row.CompletedDate,
                            revertQty: parseFloat(row.RevertQty || 0)

                        });

                        grouped[row.ProductionID].totalSqFeet += parseFloat(row.SqFeet || 0);
                        grouped[row.ProductionID].totalQty += parseFloat(row.totQty);
                        grouped[row.ProductionID].AllocatedQty += parseFloat(row.AllocatedQty);

                        grouped[row.ProductionID].RevertQty += parseFloat(row.RevertQty);

                        grouped[row.ProductionID].balanceQty += parseFloat(row.CompletedQty);
                    });

                    $.each(grouped, function (key, value) {

                        var hasStarted = value.details.some(function (d) {
                            return d.usedQty > 0;
                        });

                        if (hasStarted) {
                            value.status = "Work Started";
                        }

                        // check if ALL items are stage2 completed
                        var allStage1Done = value.details.length > 0 &&
                            value.details.every(function (d) {
                                return d.stage1compDate !== null &&
                                    d.stage1compDate !== "" &&
                                    d.stage1compDate !== undefined;
                            });

                        // ❌ skip fully completed work orders
                        if (!allStage1Done) {
                            AssignWorkOrders.push(value);
                        }
                    });

                    AssignWorkOrders.sort(function (a, b) {
                        return a.rankNo - b.rankNo;
                    });
                    bindTodaysWorkOrders();
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Work Orders data");
                }
            });
        }

        function formatDate_ddMMyyyy(dateStr) {

            if (!dateStr) return "";

            var d = new Date(dateStr);

            if (isNaN(d.getTime())) return dateStr;

            var day = ("0" + d.getDate()).slice(-2);
            var month = ("0" + (d.getMonth() + 1)).slice(-2);
            var year = d.getFullYear();

            return day + "-" + month + "-" + year;
        }

        function bindTodaysWorkOrders() {
            var count = 1;
            var html = "<table id='todaystable'>";
            html += "<thead>";
            html += "<tr>";
            html += "<th>Sr.No.</th>";
            html += "<th></th>";
            html += "<th>WO No</th>";
            html += "<th>Scheduled Date</th>";
            html += "<th>Customer</th>";
            html += "<th>Total Sq Feet</th>";
            html += "<th>Total Qty</th>";
            html += "<th>Allocated Qty</th>";
            html += "<th>Completed Qty</th>";
            html += "<th>Revert Qty</th>";
            html += "<th>Status</th>";
            html += "</tr>";
            html += "</thead>";

            html += "<tbody>";
            $.each(AssignWorkOrders, function (i, wo) {
                html += "<tr class='drag-row' data-id='" + wo.woId + "'>";
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='toggleDetails(" + wo.woId + ")'>+</button></td>";
                html += "<td style='font-weight:900;color:#f5641d;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td>" + wo.AllocatedQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + wo.balanceQty + "</td>";
                html += "<td>" + wo.RevertQty + "</td>";

                var statusColor = "black";

                if (wo.status == "Machine Allocated")
                    statusColor = "#00aaff";
                else if (wo.status == "Completed")
                    statusColor = "green";
                else if (wo.status == "Work Started")
                    statusColor = "blue";


                html += "<td id='status_" + wo.woId + "' style='font-weight:bold;color:" + statusColor + "'>" +
                    wo.status +
                    "</td>";
                html += "</tr>";

                html += "<tr id='detailRow_" + wo.woId + "' style='display:none'>";
                html += "<td colspan='2'></td>";
                html += "<td colspan='9'>";
                html += "<div id='details_" + wo.woId + "'></div>";
                html += "</td>";
                html += "</tr>";
            });
            html += "</tbody>";
            html += "</table>";

            $("#woContainer").html(html);
        }

        function toggleDetails(id) {

            var row = $("#detailRow_" + id);

            if (row.is(":visible")) {
                row.hide();
                return;
            }

            buildDetails(id);
            row.show();
        }

        function buildDetails(woId) {
            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var html = "<table>";

            html += "<tr>";
            html += "<th>Product</th>";
            html += "<th>Size</th>";
            html += "<th>Original SqFt</th>";
            html += "<th>Original Qty</th>";
            html += "<th>Assigned SqFt</th>";
            html += "<th>Assigned Qty</th>";
            html += "<th>Completed Qty</th>";
            html += "<th>Reverted Qty</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + item.originalsqFeet + "</td>";
                html += "<td>" + item.originalQty + "</td>";
                html += "<td>" + item.allocatedSqFeet + "</td>";
                html += "<td>" + item.allocatedQty + "</td>";

                html += "<td>";

                var isCompleted = item.usedQty >= item.allocatedQty;

                var usedqty = parseFloat(item.usedQty);

                // disable both buttons when completed " + disableMinus +"
                var disableMinus = isCompleted ? "disabled" : "";
                var disablePlus = isCompleted ? "disabled" : "";

                html += "<button type='button' onclick='showMinusPanel(" + woId + "," + i + ")'>-</button>";
                html += " <span id='uq_" + woId + "_" + i + "'>" + usedqty + "</span> ";
                html += "<button type='button' id='plus_" + woId + "_" + i + "' " + disablePlus + " onclick='changeQty(" + woId + "," + i + ",1,false,false,\"No\")'>+</button>";
                html += "</td>";
                html += "<td>" + item.revertQty + "</td>";

                html += "</tr>";

                html += "<tr class='minusPanel' id='minusPanel_" + woId + "_" + i + "' style='display:none;background:#f8f9fa'>";
                html += "<td colspan='7' style='text-align:right;'>";

                html += "<div style='display:inline-block;padding:15px;border:1px solid #ccc;background:#9ab6dc;border-radius:6px;width:350px;text-align:left;'>";

                html += "<label style='margin-right:20px;color: red;'>";
                html += "<input style='border:1px solid red' type='checkbox' id='mistaken_" + woId + "_" + i + "'>";
                html += "Mistaken";
                html += "</label>";

                html += "<div style='margin-top:12px;text-align:right;'>";

                html += "<button type='button' class='btn btn-outline-success btn-sm' onclick='confirmMinus(" + woId + "," + i + ")'>";
                html += "Confirm";
                html += "</button>";

                html += "</div>";

                html += "</div>";

                html += "</td>";
                html += "</tr>";
            });

            html += "</table>";

            $("#details_" + woId).html(html);
        }

        function showMinusPanel(woId, index) {

            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var item = wo.details[index];

            if (item.usedQty === 0)
                return;

            var panel = $("#minusPanel_" + woId + "_" + index);
            var plusBtn = $("#plus_" + woId + "_" + index);

            // If already open, close it and enable +
            if (panel.is(":visible")) {
                panel.hide();
                plusBtn.prop("disabled", false);
                return;
            }

            // Close all open panels
            $(".minusPanel").hide();

            // Enable all plus buttons
            $("button[id^='plus_']").prop("disabled", false);

            // Show current panel
            panel.show();

            // Disable current plus button
            plusBtn.prop("disabled", true);
        }

        function confirmMinus(woId, index) {

            var mistaken = $("#mistaken_" + woId + "_" + index).is(":checked");
          
            if (!mistaken) {
                alert("Select Mistaken");
                return;
            }

            // Hide panel
            $("#minusPanel_" + woId + "_" + index).hide();

            // Existing quantity change
            changeQty(
                woId,
                index,
                -1,
                mistaken,
                false,
                'NO'
            );
        }

        function changeQty(woId, index, delta, mistaken, faulty, reason) {
            var key = woId + "_" + index;

            // 🚫 prevent multiple fast clicks
            if (qtyUpdating[key]) return;

            qtyUpdating[key] = true;

            var wo = AssignWorkOrders.find(x => x.woId == woId);
            var item = wo.details[index];

            var newQty = item.usedQty + delta;

            var s2CompQty = item.s2ComQty || 0;

            // Prevent minus when S2 completed qty is null or 0
            if (delta < 0 && s2CompQty != 0) {
                alert("You cannot reduce quantity because Stage 2 already started working.");
                qtyUpdating[key] = false;
                return;
            }

            //if (item.usedQty >= item.allocatedQty && delta < 0) {
            //    alert("This item is already completed. You cannot reduce quantity.");
            //    return;
            //}

            if (newQty < 0) {
                alert("Completed Qty cannot be less than 0.");
                qtyUpdating[key] = false;
                return;
            }

            if (newQty > item.allocatedQty) {
                alert("Allocated Qty already completed.");
                qtyUpdating[key] = false;
                return;
            }

            var sqFtPerQty = item.allocatedSqFeet / item.allocatedQty;
            var completedSqFt = newQty * sqFtPerQty;

            $.ajax({
                type: "POST",
                url: "WoProductionS1.aspx/SaveCompletedQty",
                data: JSON.stringify({
                    detailedId: item.detailedId,
                    completedQty: newQty,
                    completedSqFt: completedSqFt,
                    mistaken: mistaken,
                    faulty: faulty,
                    reason: reason
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    if (response.d.Status == "Success") {

                        item.usedQty = newQty;

                        $("#uq_" + woId + "_" + index).text(item.usedQty);

                        // ✅ TOTAL COMPLETED QTY (your "balanceQty")
                        wo.balanceQty = wo.details.reduce((t, d) => t + d.usedQty, 0);

                        $("#bal_" + woId).text(wo.balanceQty);


                        wo.status = response.d.HeaderStatus;

                        // update grid status text
                        $("#status_" + woId).text(response.d.HeaderStatus);

                        // update color
                        var color = "black";

                        if (response.d.HeaderStatus == "Machine Allocated")
                            color = "#00aaff";
                        else if (response.d.HeaderStatus == "Work Started")
                            color = "blue";
                        else if (response.d.HeaderStatus == "Completed")
                            color = "green";

                        $("#status_" + woId).css("color", color);


                        $("#mistaken_" + woId + "_" + index).prop("checked", false);
                        $("#faulty_" + woId + "_" + index).prop("checked", false);
                        $("#reason_" + woId + "_" + index).val("");
                        $("#reasonDiv_" + woId + "_" + index).hide();
                        $("#minusPanel_" + woId + "_" + index).hide();
                        $("#plus_" + woId + "_" + index).prop("disabled", false);

                        if (response.d.IsCompleted) {
                            alert("Allocated Qty Completed.");
                        }
                    }
                    else {
                        alert(response.d.Message);
                    }
                },

                complete: function () {
                    // 🔓 unlock after request finishes
                    qtyUpdating[key] = false;
                },

                error: function () {
                    alert("Error while saving quantity.");
                    qtyUpdating[key] = false;
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
                    <asp:HiddenField ID="hdnRole" runat="server" />
                    <h3 class="m-0 font-weight-bold"><b>Production Stage 1</b></h3>
                    <select id="ddlMachine" class="form-control" style="width: 155px;" onchange="machineChanged()">
                        <option value="">-Select Machine-</option>
                    </select>
                </div>
                <div class="card-body">
                    <div id="operatorInfo" style="display: none;">
                    </div>
                    <div class="box">
                        <div id="woContainer"></div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

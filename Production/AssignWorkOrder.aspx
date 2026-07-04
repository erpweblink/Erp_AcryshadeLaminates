<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignWorkOrder.aspx.cs" Inherits="AssignWorkOrder" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>


    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" />
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
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
            padding: 3px 9px;
            margin: 3px;
            cursor: pointer;
            border: 1px solid #007bff;
            background: transparent;
            color: #007bff;
            border-radius: 8px;
            font-size: 15px;
        }

            button:hover {
                background: #007bff;
                color: white;
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

        .machine-ddl {
            width: 150px;
            display: inline-block;
            background: transparent !important;
            border: 2px solid black;
            border-radius: 9px;
            color: black;
        }

            .machine-ddl option {
                background: transparent !important;
                color: black;
            }

        .locked-row {
            background: #a3a2a0 !important;
            font-weight: bold;
            cursor: not-allowed;
        }
    </style>
    <script type="text/javascript">

        /*============== PROPERTIES ==========*/
        var stageCapacity = 0;
        var selectedMachine = null;
        var machineCapacity = 0;
        var usedCapacity = 0;
        var machineData = [];
        var workOrders = [];
        var todaysWorkOrders = [];

        /* ================= INIT ================= */
        $(function () {
            loadMachines();
        });

        function autoScheduleWorkOrders() {

            if (workOrders.length === 0)
                return;

            var unscheduledWOs = workOrders.filter(function (wo) {
                return !wo.scheduledDate;
            });

            if (unscheduledWOs.length === 0)
                return;

            var saveList = [];

            // Start from today
            var currentDate = new Date();
            currentDate.setHours(0, 0, 0, 0);

            // Sort by Rank
            unscheduledWOs.sort(function (a, b) {
                return a.rankNo - b.rankNo;
            });

            scheduleNextDate(currentDate, unscheduledWOs, saveList);
        }

        function scheduleNextDate(scheduleDate, pendingWOs, saveList) {

            if (pendingWOs.length === 0) {

                saveAutoSchedule(saveList);
                return;
            }

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/GetScheduledQtyByDate",
                data: JSON.stringify({
                    scheduleDate: scheduleDate.toISOString()
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var scheduledSqFt =
                        parseFloat(response.d || 0);

                    var availableCapacity =
                        stageCapacity - scheduledSqFt;

                    var remainingCapacity =
                        availableCapacity;

                    var assignedToday = [];

                    $.each(pendingWOs, function (i, wo) {

                        var woSqFt =
                            parseFloat(wo.totalSqFeet || 0);

                        if (woSqFt <= remainingCapacity) {

                            assignedToday.push(wo);

                            saveList.push({
                                woId: wo.woId,
                                scheduleDate: scheduleDate
                            });

                            remainingCapacity -= woSqFt;
                        }
                    });

                    pendingWOs =
                        pendingWOs.filter(function (wo) {

                            return !assignedToday.some(function (a) {
                                return a.woId === wo.woId;
                            });

                        });

                    var nextDate = new Date(scheduleDate);
                    nextDate.setDate(nextDate.getDate() + 1);

                    scheduleNextDate(
                        nextDate,
                        pendingWOs,
                        saveList
                    );
                }
            });
        }

        function saveAutoSchedule(saveList) {

            if (saveList.length === 0)
                return;

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/SetScheduledDates",
                data: JSON.stringify({
                    list: saveList
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function () {

                    alert("Auto Scheduling Completed");

                    loadWorkOrder();

                    // OR full refresh
                    // window.location.reload();
                }
            });
        }

        function enableDragDrop() {
            var $table = $("#todaystable");
            $table.find("tbody").sortable({
                items: "tr.drag-row:not(.locked-row)",
                cursor: "move",
                axis: "y",
                update: function () {
                    var list = [];
                    $table.find("tbody tr.drag-row").each(function (index) {
                        list.push({
                            id: parseInt($(this).attr("data-id")),
                            rank: index + 1
                        });
                    });
                    $.ajax({
                        type: "POST",
                        url: "AssignWorkOrder.aspx/UpdateRank",
                        data: JSON.stringify({ list: list }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function () {
                        }
                    });
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

        /* ================= MACHINES ================= */
        function loadMachines() {
            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/GetMachineDetails",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    machineData = JSON.parse(response.d);
                    $.each(machineData, function (i, m) {
                        stageCapacity += parseInt(m.MachineCapacity)
                    });
                    $("#stageCApacity").text(stageCapacity);
                    bindMachines();

                    var ddl = $("#ddlMachineFilter");
                    ddl.empty();
                    ddl.append("<option value='all'>All Machines</option>");

                    $.each(machineData, function (i, m) {
                        ddl.append("<option value='" + m.MachineID + "'>" + m.MachineName + "</option>");
                    });
                    loadWorkOrder();

                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading machine data");
                }
            });
        }

        function bindMachines() {
            var html = "<table>";
            html += "<tr><th>Select</th><th>Stage</th><th>Name</th><th>Capacity (SqFt)</th><th>Available (SqFt)</th><th>Allocated (SqFt)</th><th>Over Time (SqFt)</th><th>Load Per(%)</th></tr>";

            $.each(machineData, function (i, m) {

                var load = parseFloat(m.LoadPercentage);

                var badgeClass =
                    load >= 100 ? "bg-danger" :
                        load >= 70 ? "bg-warning" :
                            "bg-success";

                var OTcap = parseFloat(m.MachineLoad) - parseFloat(m.MachineCapacity);
                var perHourQty = parseFloat(m.MachinePerHRQty);   
                // Extra hours required
                var extraHours = OTcap / perHourQty;

                // Convert to Hours & Minutes
                var hrs = Math.floor(extraHours);
                var mins = Math.round((extraHours - hrs) * 60);

                var timeRequired = hrs + " Hr " + mins + " Min";
                var extraInfo = "";

                if (OTcap > 0) {
                    extraInfo = " <small><i>(" + timeRequired + " Extra Work)</i></small>";
                }

                html += "<tr>";
                html += "<td><input type='radio' name='machine' onclick='selectMachine(" + m.MachineID + ")'></td>";
                html += "<td><span class='badge bg-info'>" + m.AllocatedStage + "</span></td>";
                html += "<td>" + m.MachineName + "</td>";
                html += "<td>" + m.MachineCapacity + "</td>";
                html += "<td>" + m.MachineAvailable + "</td>";
                html += "<td>" + m.MachineLoad + "</td>";
                html += "<td><b>" + OTcap + "</b> " + extraInfo + "</td>";
                html += "<td><span class='badge " + badgeClass + "'>"
                    + m.LoadPercentage + " %</span></td>";
                html += "</tr>";
            });

            html += "</table>";

            $("#machineContainer").html(html);
        }

        function selectMachine(id) {
            selectedMachine = machineData.find(x => x.MachineID == id);

            machineCapacity = selectedMachine.MachineAvailable;
            usedCapacity = 0;

            updateHeader();
        }

        /* ================= WORK ORDERS ================= */
        function loadWorkOrder() {
            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/GetWorkOrders",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = JSON.parse(response.d);
                    workOrders = [];
                    var grouped = {};
                    var count = 1;
                    $.each(rows, function (i, row) {
                        var MachineDtls = machineData.find(x => x.MachineID == row.MachineID);

                        if (!grouped[row.MainID]) {
                            grouped[row.MainID] = {
                                SrNo: count++,
                                woId: row.MainID,
                                rankNo: parseInt(row.RankNo),
                                woNo: row.TallyRefNo,
                                scheduledDate: row.ScheduledDate || '',
                                customer: row.CustomerName,
                                totalSqFeet: 0,
                                totalQty: 0,
                                remQty: 0,
                                balanceQty: 0,
                                status: row.Status || "Machine Not Allocated",
                                details: [],
                                isCompleted: true
                            };
                        }

                        var remainingQty = parseFloat(row.RemainingQty || 0);
                        var remainingSqFeet = parseFloat(row.RemainingSqFeet || 0);
                        grouped[row.MainID].details.push({
                            detailedId: row.DetailedID,
                            product: row.ProductName,
                            partNo: row.PartNo,
                            size: row.Size,
                            qty: remainingQty,
                            sqFeet: remainingSqFeet,

                            originalQty: parseFloat(row.Qty),
                            originalsqFeet: parseFloat(row.SqFeet || 0),
                            allocatedQty: parseFloat(row.AllocatedQty || 0),
                            allocatedSqFeet: parseFloat(row.AllocatedSqFeet || 0),

                            usedQty: 0,
                            usedSqFt: 0,

                            machineall: row.MachineID
                                ? row.MachineID
                                    .split(',')
                                    .map(id => 'M' + id.trim())
                                    .join(', ')
                                : ""
                        });



                        grouped[row.MainID].totalSqFeet += parseFloat(row.SqFeet || 0);
                        grouped[row.MainID].totalQty += parseFloat(row.Qty);
                        grouped[row.MainID].balanceQty += remainingQty;
                        grouped[row.MainID].remQty += parseFloat(row.RemainingQty || 0);

                        if (parseFloat(row.RemainingQty || 0) > 0) {
                            grouped[row.MainID].isCompleted = false;
                        }
                    });


                    $.each(grouped, function (key, value) {
                        workOrders.push(value);
                    });

                    workOrders.sort(function (a, b) {
                        var rankA = isNaN(a.rankNo) ? Number.MAX_SAFE_INTEGER : a.rankNo;
                        var rankB = isNaN(b.rankNo) ? Number.MAX_SAFE_INTEGER : b.rankNo;

                        return rankA - rankB;
                    });

                    // Get today's date in yyyy-MM-dd format
                    var today = new Date();
                    //today.setDate(today.getDate() + 1);
                    today.setHours(0, 0, 0, 0);

                    todaysWorkOrders = [];
                    var otherWorkOrders = [];

                    $.each(workOrders, function (i, wo) {
                        if (wo.scheduledDate) {

                            var schDate = new Date(wo.scheduledDate);
                            schDate.setHours(0, 0, 0, 0);

                            var isToday =
                                schDate.getTime() === today.getTime();

                            var isPendingOld =
                                schDate < today &&
                                wo.status &&
                                wo.status !== "Completed";

                            if (isPendingOld) {
                                wo.priority = 1; // 🔴 overdue (highest priority)
                                todaysWorkOrders.push(wo);
                            }
                            else if (isToday) {
                                wo.priority = 2; // 🟡 today
                                todaysWorkOrders.push(wo);
                            }
                            else {
                                otherWorkOrders.push(wo);
                            }
                        } else {
                            otherWorkOrders.push(wo);
                        }
                    });

                    todaysWorkOrders.sort(function (a, b) {
                        if (a.priority !== b.priority)
                            return a.priority - b.priority;

                        return a.rankNo - b.rankNo;
                    });

                    workOrders = otherWorkOrders;

                    // autoScheduleWorkOrders();
                    bindTodaysWorkOrders();
                    bindWorkOrders();
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Work Orders data");
                }
            });
        }

        //Todays
        function bindTodaysWorkOrders() {
            var count = 1;
            var html = "<table id='todaystable'>";
            html += "<thead>";
            html += "<tr>";
            html += "<th></th>";
            html += "<th>Sr.No.</th>";
            html += "<th></th>";
            html += "<th>WO No</th>";
            html += "<th>Scheduled Date</th>";
            html += "<th>Customer</th>";
            html += "<th>Total Sq Feet</th>";
            html += "<th>Total Qty</th>";
            html += "<th>Balance</th>";
            html += "<th>Status</th>";
            html += "</tr>";
            html += "</thead>";

            html += "<tbody>";
            $.each(todaysWorkOrders, function (i, wo) {
                var isLocked = (wo.status === "Work Started" || wo.status === "Partially Completed");

                var badges = wo.balanceQty;
                var badgeHtml = "";
                debugger;
                if (badges === 0) {
                    badgeHtml = "<span class='badge bg-success'>" + badges + "</span>";
                } else {
                    badgeHtml = "<span class='badge bg-danger'>" + badges + "</span>";
                }

                html += "<tr class='drag-row " + (isLocked ? "locked-row" : "") + "'   data-id='" + wo.woId + "'>";
                if (wo.isCompleted) {
                    html += "<td><input type='checkbox' disabled></td>";
                }
                else {
                    html += "<td><input type='checkbox' onchange='toggleWO(" + wo.woId + ",this)'></td>";
                }
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='toggleDetails(" + wo.woId + ")'>+</button></td>";
                html += "<td style='font-weight:900;color:#f5641d;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + badgeHtml + "</td>";

                var statusColor = "black";

                if (wo.status == "Machine Allocated")
                    statusColor = "#00aaff";
                else if (wo.status == "Completed")
                    statusColor = "green";
                else if (wo.status == "Machine Not Allocated")
                    statusColor = "red";
                else if (wo.status == "Work Started")
                    statusColor = "blue";


                html += "<td style='font-weight:bold;color:" + statusColor + "'>" +
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
            enableDragDrop();
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
            var wo = todaysWorkOrders.find(x => x.woId == woId);

            var html = "<table>";

            html += "<tr>";
            html += "<th>Product</th>";
            html += "<th>Size</th>";
            html += "<th>Original SqFt</th>";
            html += "<th>Original Qty</th>";
            html += "<th>Remaining SqFt</th>";
            html += "<th>Remaining Qty</th>";
            html += "<th>Used Qty</th>";
            html += "<th>Used SqFt</th>";
            html += "<th>Machine</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                var badges = item.machineall;
                var badgeHtml = badges;

                if (badges === "M1") {
                    badgeHtml = "<span class='badge bg-success'>M1</span>";
                }
                else if (badges === "M2") {
                    badgeHtml = "<span class='badge bg-warning text-dark'>M2</span>";
                } else if (badges === "M1, M2") {
                    badgeHtml = "<span class='badge bg-success'>M1</span>" + " " + "<span class='badge bg-warning text-dark'>M2</span>";
                } else {
                    badgeHtml = "<span class='badge bg-danger'>N/A</span>";
                }

                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + item.originalsqFeet + "</td>";
                html += "<td>" + item.originalQty + "</td>";
                html += "<td>" + item.sqFeet + "</td>";
                html += "<td>" + item.qty + "</td>";

                html += "<td>";
                html += "<button type='button' onclick='changeQty(" + woId + "," + i + ",-1)'>-</button>";
                html += " <span id='uq_" + woId + "_" + i + "'>" + item.usedQty + "</span> ";
                html += "<button type='button' onclick='changeQty(" + woId + "," + i + ",1)'>+</button>";
                html += "</td>";

                html += "<td id='us_" + woId + "_" + i + "'>" + item.usedSqFt + "</td>";

                html += "<td>" + badgeHtml + "</td>";

                html += "</tr>";
            });

            html += "</table>";

            $("#details_" + woId).html(html);
        }

        function filterTodaysByMachine() {

            var selectedId = $("#ddlMachineFilter").val();

            var filtered = todaysWorkOrders;
            if (selectedId !== "all") {
                filtered = todaysWorkOrders.filter(x =>
                    x.machineName !== "Not Allocated" &&
                    machineData.find(m => m.MachineID == selectedId)?.MachineName === x.machineName
                );
                renderTodaysFiltered(filtered);
            } else {
                window.location.href = window.location.href;
            }
        }

        function renderTodaysFiltered(list) {

            var count = 1;
            var html = "<table id='todaystable'>";
            html += "<thead>";
            html += "<tr>";
            html += "<th></th>";
            html += "<th>Sr.No.</th>";
            html += "<th></th>";
            html += "<th>WO No</th>";
            html += "<th>Scheduled Date</th>";
            html += "<th>Customer</th>";
            html += "<th>Total Sq Feet</th>";
            html += "<th>Total Qty</th>";
            html += "<th>Balance</th>";
            html += "<th>Status</th>";
            html += "<th>Machine Name</th>";
            html += "</tr>";
            html += "</thead>";

            html += "<tbody>";
            $.each(list, function (i, wo) {

                var isLocked = (wo.status === "Work Started" || wo.status === "Completed");

                html += "<tr class='drag-row " + (isLocked ? "locked-row" : "") + "'  data-id='" + wo.woId + "'>";
                if (wo.isCompleted) {
                    html += "<td><input type='checkbox' disabled></td>";
                }
                else {
                    html += "<td><input type='checkbox' onchange='toggleWO(" + wo.woId + ",this)'></td>";
                }
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='toggleDetails(" + wo.woId + ")'>+</button></td>";
                html += "<td style='font-weight:900;color:#f5641d;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + wo.balanceQty + "</td>";

                var statusColor = "black";

                if (wo.status == "Machine Allocated")
                    statusColor = "#00aaff";
                else if (wo.status == "Completed")
                    statusColor = "green";
                else if (wo.status == "Machine Not Allocated")
                    statusColor = "red";
                else if (wo.status == "Work Started")
                    statusColor = "blue";

                html += "<td style='font-weight:bold;color:" + statusColor + "'>" +
                    wo.status +
                    "</td>";
                html += "<td><span class='badge bg-success'>" + wo.machineName + "</span></td>";
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
            // re-enable sorting after re-render
            enableDragDrop();
        }

        //All List 
        function bindWorkOrders() {
            var count = 1;
            var html = "<table>";
            html += "<tr>";
            html += "<th></th>";
            html += "<th>Sr.No.</th>";
            html += "<th></th>";
            html += "<th>WO No</th>";
            html += "<th>Scheduled Date</th>";
            html += "<th>Customer</th>";
            html += "<th>Total Sq Feet</th>";
            html += "<th>Total Qty</th>";
            html += "<th>Balance</th>";
            html += "</tr>";

            $.each(workOrders, function (i, wo) {

                html += "<tr>";
                html += "<td><input type='checkbox' onchange='togglesWO(" + wo.woId + ",this)'></td>";
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='togglesDetails(" + wo.woId + ")'>+</button></td>";
                html += "<td style='font-weight:900;color:#f5641d;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + wo.balanceQty + "</td>";
                html += "</tr>";

                html += "<tr id='detailsRow_" + wo.woId + "' style='display:none'>";
                html += "<td colspan='2'></td>";
                html += "<td colspan='7'>";
                html += "<div id='detailss_" + wo.woId + "'></div>";
                html += "</td>";
                html += "</tr>";
            });

            html += "</table>";

            $("#woContainer1").html(html);
        }

        function togglesDetails(id) {

            var row = $("#detailsRow_" + id);

            if (row.is(":visible")) {
                row.hide();
                return;
            }

            buildsDetails(id);
            row.show();
        }

        function buildsDetails(woId) {

            var wo = workOrders.find(x => x.woId == woId);

            var html = "<table>";

            html += "<tr>";
            html += "<th>Product</th>";
            html += "<th>Size</th>";
            html += "<th>SqFt</th>";
            html += "<th>Qty</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + item.sqFeet + "</td>";
                html += "<td>" + item.qty + "</td>";
                html += "</tr>";
            });

            html += "</table>";

            $("#detailss_" + woId).html(html);
        }

        /* ================= WORK ORDER SELECT ================= */
        var selectedWOs = [];
        function togglesWO(woId, chk) {

            var scheduleDate = $("#<%= txtdate.ClientID %>").val();

            if (!scheduleDate) {
                alert("Please select a Schedule Date first.");
                chk.checked = false;
                return;
            }

            var wo = workOrders.find(x => x.woId == woId);

            if (!wo) return;

            if (!chk.checked) {
                selectedWOs = selectedWOs.filter(x => x.woId != woId);

                var usedCapacity = 0; // or a global variable

                $.each(selectedWOs, function (i, item) {
                    usedCapacity += parseFloat(item.totalSqFeet || 0);
                });

                $("#usedCapacity").text(usedCapacity || 0);
                return;
            }

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/GetScheduledQtyByDate",
                data: JSON.stringify({ scheduleDate: scheduleDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    // Qty/SqFt already scheduled in DB for this date
                    var scheduledSqFt = parseFloat(response.d || 0);

                    var stageCapacity = parseFloat($("#stageCApacity").text()) || 0;

                    // Qty selected on screen
                    var selectedSqFt = 0;
                    $.each(selectedWOs, function (i, item) {
                        selectedSqFt += parseFloat(item.totalSqFeet || 0);
                    });


                    var currentWoSqFt = parseFloat(wo.totalSqFeet || 0);


                    //var availableSqFt =
                    //    stageCapacity -
                    //    scheduledSqFt -
                    //    selectedSqFt;

                    //if (currentWoSqFt > availableSqFt) {

                    //    alert(
                    //        "Cannot select this Work Order.\n\n" +
                    //        "Schedule Date : " + scheduleDate + "\n" +
                    //        "Stage Capacity : " + stageCapacity + "\n" +
                    //        "Already Scheduled : " + scheduledSqFt + "\n" +
                    //        "Currently Selected : " + selectedSqFt + "\n" +
                    //        "Available SqFt : " + availableSqFt + "\n" +
                    //        "Current WO SqFt : " + currentWoSqFt
                    //    );

                    //    chk.checked = false;
                    //    return;
                    //}

                    selectedWOs.push({
                        woId: woId,
                        scheduleDate: scheduleDate,
                        totalSqFeet: parseFloat(wo.totalSqFeet || 0)
                    });

                    var usedCapacity = scheduledSqFt;
                    $.each(selectedWOs, function (i, item) {
                        usedCapacity += parseFloat(item.totalSqFeet || 0);
                    });

                    $("#usedCapacity").text(usedCapacity);
                },
                error: function () {
                    alert("Error checking available capacity.");
                    chk.checked = false;
                }
            });
        }

        var MachineAllocatedWOs = [];

        function updateMachineAllocatedWO(wo) {

            var existingIndex = MachineAllocatedWOs.findIndex(x => x.woId == wo.woId);

            var allocation = {
                woId: wo.woId,
                woNo: wo.woNo,
                machineId: selectedMachine.MachineID,
                machineName: selectedMachine.MachineName,
                totalQty: wo.totalQty,
                AssignedDate: wo.scheduledDate,
                totalSqFeet: wo.totalSqFeet,
                balanceQty: wo.balanceQty,
                // allocatedQty: wo.totalQty - wo.balanceQty,
                allocatedQty: wo.remQty - wo.balanceQty,
                details: []
            };

            $.each(wo.details, function (i, item) {

                allocation.details.push({
                    detailedId: item.detailedId,
                    product: item.product,
                    partNo: item.partNo,
                    size: item.size,
                    orgQty: item.originalQty,
                    qty: item.qty,
                    sqFeet: item.sqFeet,
                    usedQty: item.usedQty,
                    usedSqFt: item.usedSqFt
                });

            });

            if (existingIndex >= 0)
                MachineAllocatedWOs[existingIndex] = allocation;
            else
                MachineAllocatedWOs.push(allocation);
        }

        var selectedTodayWOs = [];
        function toggleWO(woId, chk) {
            if (!selectedMachine) {
                alert("Select Machine First");
                chk.checked = false;
                return;
            }

            var wo = todaysWorkOrders.find(x => x.woId == woId);

            //if (wo.machineName !== "Not Allocated") {
            //    if (selectedMachine.MachineName !== wo.machineName) {
            //        alert(`Please send work order to ${wo.machineName}`);
            //        chk.checked = false;
            //        return;
            //    }
            //}

            if (chk.checked) {
                selectedTodayWOs.push(wo);
                var allocated = autoAllocateWO(wo);
                if (!allocated) {
                    selectedTodayWOs =
                        selectedTodayWOs.filter(x => x.woId != wo.woId);
                    chk.checked = false;
                    return;
                }
            }
            else {
                selectedTodayWOs = selectedTodayWOs.filter(x => x.woId != wo.woId);
                releaseWO(wo);
                redistributeCapacity();
            }

            updateHeader();
        }

        function redistributeCapacity() {

            usedCapacity = 0;

            $.each(selectedTodayWOs, function (i, wo) {

                $.each(wo.details, function (j, item) {

                    item.usedQty = 0;
                    item.usedSqFt = 0;

                    $("#uq_" + wo.woId + "_" + j).text(0);
                    $("#us_" + wo.woId + "_" + j).text(0);
                });

                wo.balanceQty = wo.totalQty;
            });

            MachineAllocatedWOs = [];

            $.each(selectedTodayWOs, function (i, wo) {

                autoAllocateWO(wo);

                updateBalance(wo.woId);
            });
        }

        /* ================= FIX 1: autoAllocateWO ================= */
        function autoAllocateWO(wo) {

            var remainingCapacity = machineCapacity - usedCapacity;

            if (remainingCapacity <= 0) {
                alert("No machine capacity available");
                return false;
            }

            $.each(wo.details, function (i, item) {
                var sqFtPerQty = item.sqFeet / item.qty;

                if (isNaN(sqFtPerQty)) sqFtPerQty = 0;
                var possibleQty = Math.floor(remainingCapacity / sqFtPerQty);

                item.usedQty = Math.min(possibleQty, item.qty);

                item.usedSqFt = item.usedQty * sqFtPerQty;

                usedCapacity += item.usedSqFt;
                remainingCapacity -= item.usedSqFt;

                $("#uq_" + wo.woId + "_" + i).text(item.usedQty);
                $("#us_" + wo.woId + "_" + i).text(item.usedSqFt);

            });

            updateBalance(wo.woId);
            updateHeader();

            updateMachineAllocatedWO(wo);

            if ($("#detailRow_" + wo.woId).is(":visible")) {
                buildDetails(wo.woId);
            }
            return true;
        }

        /* ================= FIX 2: releaseWO ================= */
        function releaseWO(wo) {

            $.each(wo.details, function (i, item) {

                var sqFtPerQty = item.sqFeet / item.qty;

                usedCapacity -= (item.usedQty * sqFtPerQty);

                item.usedQty = 0;

                $("#uq_" + wo.woId + "_" + i).text(0);
                $("#us_" + wo.woId + "_" + i).text("0");
            });

            if (usedCapacity < 0)
                usedCapacity = 0;

            updateBalance(wo.woId);
            updateHeader();

            MachineAllocatedWOs =
                MachineAllocatedWOs.filter(x => x.woId != wo.woId);
        }

        /* ================= FIX 3: changeQty ================= */
        function changeQty(woId, index, action) {

            var wo = todaysWorkOrders.find(x => x.woId == woId);
            var item = wo.details[index];

            var sqFtPerQty = item.sqFeet / item.qty;

            if (action == 1) {

                if (item.usedQty >= item.qty) {
                    return;
                }

                if ((usedCapacity + sqFtPerQty) > machineCapacity) {
                    alert("Machine capacity exceeded.");
                    return;
                }

                item.usedQty++;
                usedCapacity += sqFtPerQty;
            }
            else {

                if (item.usedQty <= 0)
                    return;

                item.usedQty--;
                usedCapacity -= sqFtPerQty;
            }

            var usedSqFt = item.usedQty * sqFtPerQty;

            $("#uq_" + woId + "_" + index).text(item.usedQty);
            $("#us_" + woId + "_" + index).text(usedSqFt);

            updateBalance(woId);
            updateHeader();
            wo.details[index].usedSqFt = usedSqFt;
            updateMachineAllocatedWO(wo);
        }

        /* ================= BALANCE ================= */
        function updateBalance(woId) {

            //var wo = todaysWorkOrders.find(x => x.woId == woId);

            //var allocatedQty = 0;

            //$.each(wo.details, function (i, item) {
            //    allocatedQty += item.usedQty;
            //});

            //wo.balanceQty = wo.totalQty - allocatedQty;

            //$("#bal_" + woId).text(wo.balanceQty);

            var wo = todaysWorkOrders.find(x => x.woId == woId);

            var allocatedQty = 0;

            $.each(wo.details, function (i, item) {
                allocatedQty += item.usedQty;
            });

            // Remaining qty of THIS allocation cycle
            wo.balanceQty = wo.remQty - allocatedQty;

            if (wo.balanceQty < 0)
                wo.balanceQty = 0;

            $("#bal_" + woId).text(wo.balanceQty);
        }

        /* ================= HEADER ================= */
        function updateHeader() {

            var remaining = machineCapacity - usedCapacity;

            if (remaining < 0)
                remaining = 0;

            $("#capacityInfo").text(
                usedCapacity +
                " / " +
                machineCapacity +
                " (Remaining: " +
                remaining +
                ")"
            );
        }

        /* ================= SAVE ================= */
        function saveAllocation() {
            if (MachineAllocatedWOs.length == 0) {
                alert("No Work Orders Allocated");
                return;
            }

            // Remove WOs that have 0 allocated qty
            var validAllocations = MachineAllocatedWOs.filter(function (wo) {

                var totalUsedQty = 0;

                $.each(wo.details, function (i, item) {
                    totalUsedQty += parseFloat(item.usedQty || 0);
                });

                return totalUsedQty > 0;
            });

            if (validAllocations.length == 0) {
                alert("Selected work orders have 0 allocated quantity. Cannot send to production.");
                window.location.href = window.location.href;
                return;
            }

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/SaveMachineAllocation",
                data: JSON.stringify({ allocations: MachineAllocatedWOs }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    alert("Allocation Saved Successfully");

                    MachineAllocatedWOs = [];

                    window.location.href = window.location.href;
                },
                error: function (xhr) {
                    alert("Error while saving allocation");
                }
            });
        }

        function SetScheduledDates() {
            if (selectedWOs.length === 0) {
                alert("Please select at least one Work Order.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "AssignWorkOrder.aspx/SetScheduledDates",
                data: JSON.stringify({ list: selectedWOs }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    alert("Work Orders scheduled successfully!");

                    selectedWOs = [];
                    $("#<%= txtdate.ClientID %>").val('');
                    $("#usedCapacity").text('0');

                    window.location.href = window.location.href;
                    // loadWorkOrder(); // reload grid
                },
                error: function () {
                    alert("Error while saving schedule.");
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
                    <h3 class="m-0 font-weight-bold"><b>Scheduling/Allotment</b></h3>
                </div>
                <div class="card-body">
                    <div class="box">
                        <center>
                            <h4 style="color: #eb7025; font-weight: 900;">Machine Capacity</h4>
                        </center>
                        <div id="machineContainer"></div>
                        <hr>
                        <br />
                        <h4 class="m-0 font-weight-bold" style="color: #eb7025; font-weight: 900;">Todays Orders 
                                <b class="badge bg-success" style="color: whitesmoke; font-size: medium;"><i><span id="lblDate" runat="server"></span></i></b>
                            <select id="ddlMachineFilter" onchange="filterTodaysByMachine()" class="form-control machine-ddl d-none">
                                <option value="all">All Machines</option>
                            </select>
                            <span style="float: right">Capacity Used (SqFt):
                                    <span id="capacityInfo">0 / 0</span>
                            </span>
                        </h4>
                        <div id="woContainer"></div>
                        <button type="button" class="mt-2" onclick="saveAllocation()">Multiple Send</button>
                    </div>
                    <br />
                    <br />
                    <div class="box">
                        <div class="row align-items-center">

                            <div class="col-md-3">
                                <h4 class="m-0 font-weight-bold" style="color: #eb7025; font-weight: 900;">Work Orders List</h4>
                                <asp:TextBox ID="txtdate" runat="server"
                                    CssClass="form-control"
                                    TextMode="Date"></asp:TextBox>
                            </div>

                            <div class="col-md-6 text-center">
                                <span style="color: #258eeb; font-weight: 900; font-size: 30px;">Stage Capacity - <span id="stageCApacity">0</span>
                                </span>
                                <br />
                                <span style="color: #258eeb; font-weight: 900; font-size: 30px;">Used Capacity - <span id="usedCapacity">0</span>
                                </span>
                            </div>

                            <div class="col-md-3 text-end">
                                <button type="button"
                                    class="btn btn-outline-success btn-sm"
                                    onclick="SetScheduledDates()">
                                    Schedule W/O
                                </button>
                            </div>
                        </div>
                        <div class="mt-1" id="woContainer1"></div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

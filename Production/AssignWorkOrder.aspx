<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="AssignWorkOrder.aspx.cs" Inherits="AssignWorkOrder" %>

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
            loadWorkOrder();
        });

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
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading machine data");
                }
            });
        }

        function bindMachines() {
            var html = "<table>";
            html += "<tr><th>Select</th><th>Stage</th><th>Name</th><th>Capacity</th><th>Load</th><th>Available</th><th>Load Per</th></tr>";

            $.each(machineData, function (i, m) {

                var load = parseFloat(m.LoadPercentage);

                var badgeClass =
                    load >= 100 ? "bg-danger" :
                        load >= 70 ? "bg-warning" :
                            "bg-success";

                html += "<tr>";
                html += "<td><input type='radio' name='machine' onclick='selectMachine(" + m.MachineID + ")'></td>";
                html += "<td><span class='badge bg-info'>" + m.AllocatedStage + "</span></td>";
                html += "<td>" + m.MachineName + "</td>";
                html += "<td>" + m.MachineCapacity + "</td>";
                html += "<td>" + m.MachineLoad + "</td>";
                html += "<td>" + m.MachineAvailable + "</td>";
                html += "<td><span class='badge " + badgeClass + "'>"
                    + m.LoadPercentage + " %</span></td>";
                html += "</tr>";
            });

            html += "</table>";

            $("#machineContainer").html(html);
        }

        function selectMachine(id) {
            selectedMachine = machineData.find(x => x.MachineID == id);

            machineCapacity = selectedMachine.MachineCapacity;
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
                                balanceQty: 0,
                                status: "Pending",
                                details: []
                            };
                        }
                        grouped[row.MainID].details.push({
                            detailedId: row.DetailedID,
                            product: row.ProductName,
                            partNo: row.PartNo,
                            size: row.Size,
                            qty: parseFloat(row.Qty),
                            sqFeet: parseFloat(row.SqFeet || 0),
                            usedQty: 0,
                            usedSqFt: 0
                        });
                        grouped[row.MainID].totalSqFeet += parseFloat(row.SqFeet || 0);
                        grouped[row.MainID].totalQty += parseFloat(row.Qty);
                        grouped[row.MainID].balanceQty += parseFloat(row.Qty);
                    });

                    $.each(grouped, function (key, value) {
                        workOrders.push(value);
                    });
                    workOrders.sort(function (a, b) {
                        return a.rankNo - b.rankNo;
                    });
                    // Get today's date in yyyy-MM-dd format
                    var today = new Date();
                    today.setHours(0, 0, 0, 0);

                    todaysWorkOrders = [];
                    var otherWorkOrders = [];

                    $.each(workOrders, function (i, wo) {
                        if (wo.scheduledDate) {

                            var schDate = new Date(wo.scheduledDate);
                            schDate.setHours(0, 0, 0, 0);

                            if (schDate.getTime() === today.getTime()) {
                                todaysWorkOrders.push(wo);
                            } else {
                                otherWorkOrders.push(wo);
                            }
                        } else {
                            otherWorkOrders.push(wo);
                        }
                    });

                    workOrders = otherWorkOrders;

                    bindTodaysWorkOrders();
                    bindWorkOrders();
                },
                error: function (xhr, status, error) {
                    console.log(error);
                    alert("Error loading Work Orders data");
                }
            });
        }

        function bindTodaysWorkOrders() {
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

            $.each(todaysWorkOrders, function (i, wo) {

                html += "<tr>";
                html += "<td><input type='checkbox' onchange='toggleWO(" + wo.woId + ",this)'></td>";
                html += "<td>" + count++ + "</td>";
                html += "<td><button type='button' onclick='toggleDetails(" + wo.woId + ")'>+</button></td>";
                html += "<td style='font-weight:900;color:red;'>" + wo.woNo + "</td>";
                html += "<td>" + formatDate_ddMMyyyy(wo.scheduledDate) + "</td>";
                html += "<td>" + wo.customer + "</td>";
                html += "<td>" + wo.totalSqFeet + "</td>";
                html += "<td>" + wo.totalQty + "</td>";
                html += "<td id='bal_" + wo.woId + "'>" + wo.balanceQty + "</td>";
                html += "</tr>";

                html += "<tr id='detailRow_" + wo.woId + "' style='display:none'>";
                html += "<td colspan='2'></td>";
                html += "<td colspan='7'>";
                html += "<div id='details_" + wo.woId + "'></div>";
                html += "</td>";
                html += "</tr>";
            });

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

            var wo = todaysWorkOrders.find(x => x.woId == woId);

            var html = "<table>";

            html += "<tr>";
            html += "<th>Product</th>";
            html += "<th>Part No</th>";
            html += "<th>Size</th>";
            html += "<th>SqFt</th>";
            html += "<th>Qty</th>";
            html += "<th>Used Qty</th>";
            html += "<th>Used SqFt</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.partNo + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + item.sqFeet + "</td>";
                html += "<td>" + item.qty + "</td>";

                html += "<td>";
                html += "<button type='button' onclick='changeQty(" + woId + "," + i + ",-1)'>-</button>";
                html += " <span id='uq_" + woId + "_" + i + "'>" + item.usedQty + "</span> ";
                html += "<button type='button' onclick='changeQty(" + woId + "," + i + ",1)'>+</button>";
                html += "</td>";

                html += "<td id='us_" + woId + "_" + i + "'>" + item.usedSqFt + "</td>";

                html += "</tr>";
            });

            html += "</table>";

            $("#details_" + woId).html(html);
        }

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
                html += "<td style='font-weight:900;color:red;'>" + wo.woNo + "</td>";
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
            html += "<th>Part No</th>";
            html += "<th>Size</th>";
            html += "<th>SqFt</th>";
            html += "<th>Qty</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.partNo + "</td>";
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

                   var availableSqFt =
                       stageCapacity -
                       scheduledSqFt -
                       selectedSqFt;

                   if (currentWoSqFt > availableSqFt) {

                       alert(
                           "Cannot select this Work Order.\n\n" +
                           "Schedule Date : " + scheduleDate + "\n" +
                           "Stage Capacity : " + stageCapacity + "\n" +
                           "Already Scheduled : " + scheduledSqFt + "\n" +
                           "Currently Selected : " + selectedSqFt + "\n" +
                           "Available SqFt : " + availableSqFt + "\n" +
                           "Current WO SqFt : " + currentWoSqFt
                       );

                       chk.checked = false;
                       return;
                   }

                   selectedWOs.push({
                       woId: woId,
                       scheduleDate: scheduleDate,
                       totalSqFeet: parseFloat(wo.totalSqFeet || 0)
                   });
               },
               error: function () {
                   alert("Error checking available capacity.");
                   chk.checked = false;
               }
           });
       }


        function toggleWO(woId, chk) {
            if (!selectedMachine) {
                alert("Select Machine First");
                chk.checked = false;
                return;
            }

            var wo = todaysWorkOrders.find(x => x.woId == woId);

            if (chk.checked) {

                autoAllocateWO(wo);

            } else {

                releaseWO(wo);
            }

            updateHeader();
        }

        /* ================= FIX 1: autoAllocateWO ================= */
        function autoAllocateWO(wo) {

            var remainingCapacity = machineCapacity - usedCapacity;

            if (remainingCapacity <= 0) {
                alert("No machine capacity available");
                return;
            }

            $.each(wo.details, function (i, item) {
                var sqFtPerQty = item.sqFeet / item.qty;

                var possibleQty = Math.floor(remainingCapacity / sqFtPerQty);

                item.usedQty = Math.min(possibleQty, item.qty);

                item.usedSqFt = item.usedQty * sqFtPerQty;

                usedCapacity += item.usedSqFt;
                remainingCapacity -= item.usedSqFt;

                $("#uq_" + wo.woId + "_" + i).text(item.usedQty);
                $("#us_" + wo.woId + "_" + i).text(item.usedSqFt);

                if (remainingCapacity <= 0) {
                    return false;
                }
            });

            updateBalance(wo.woId);
            updateHeader();

            if ($("#detailRow_" + wo.woId).is(":visible")) {
                buildDetails(wo.woId);
            }
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
        }

        /* ================= BALANCE ================= */
        function updateBalance(woId) {

            var wo = todaysWorkOrders.find(x => x.woId == woId);

            var allocatedQty = 0;

            $.each(wo.details, function (i, item) {
                allocatedQty += item.usedQty;
            });

            wo.balanceQty = wo.totalQty - allocatedQty;

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

            console.log({
                machine: selectedMachine,
                usedCapacity: usedCapacity,
                workOrders: workOrders
            });

            alert("Saved (check console)");
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
                    loadWorkOrder(); // reload grid
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
                    <h3 class="m-0 font-weight-bold"><b>Start Production</b></h3>
                </div>
                <div class="card-body">
                    <div class="box">
                        <center>
                            <h4 style="color: #eb7025; font-weight: 900;">Machine Capacity</h4>
                        </center>
                        <div id="machineContainer"></div>
                        <hr>
                        <h4 class="m-0 font-weight-bold" style="color: #eb7025; font-weight: 900;">Todays Orders ( 
                                <b style="color: green; font-size: medium;"><span id="lblDate" runat="server"></span></b>)
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
                                <h4 style="color: #eb7025; font-weight: 900; font-size: 30px;">Stage Capacity - <span id="stageCApacity">0</span>
                                </h4>
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

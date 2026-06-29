<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="Packaging.aspx.cs" Inherits="Packaging" %>


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



        /*CSS fro Image Pop UP*/
        .product-image-preview {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
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

        /*END*/
    </style>
    <script type="text/javascript">
        var AssignWorkOrders = [];
        var qtyUpdating = {};
        $(function () {
            loadWorkOrder();
        });

        function loadWorkOrder() {
            $.ajax({
                type: "POST",
                url: "Packaging.aspx/GetAssignWorkOrders",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = JSON.parse(response.d);
                    AssignWorkOrders = [];
                    var grouped = {};

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
                                competeQty: 0,
                                details: [],
                                isCompleted: true,
                                date: row.PackagingFinalDate || ''
                            };
                        }

                        grouped[row.ProductionID].details.push({
                            detailedId: row.DetailedID,
                            product: row.ProductName,
                            size: row.Size,

                            originalQty: parseFloat(row.totQty),
                            originalsqFeet: parseFloat(row.SqFeet || 0),

                            allocatedQty: parseFloat(row.CompletedQty || 0),
                            allocatedSqFeet: parseFloat(row.CompetedSqFeet || 0),

                            usedQty: parseFloat(row.PackagingQty || 0),
                            compDate: row.PackagingRevertQty,
                            imagename: row.ImageName
                        });

                        grouped[row.ProductionID].totalSqFeet += parseFloat(row.SqFeet || 0);
                        grouped[row.ProductionID].totalQty += parseFloat(row.totQty);
                        grouped[row.ProductionID].competeQty += parseFloat(row.PackagingQty);
                    });

                    $.each(grouped, function (key, value) {

                        AssignWorkOrders.push(value);
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
            html += "<th>Balance Qty</th>";
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
                html += "<td id='bal_" + wo.woId + "'>" + wo.competeQty + "</td>";


                html += "<td>";
                html += "<span id='status_" + wo.woId + "' ";
                html += "style='font-size: 27px;color: gray;cursor: pointer;font-weight: bolder;' ";
                html += "onclick='toggleTick(" + wo.woId + ")'>";
                html += "&#10004;"; // ✓
                html += "</span>";
                html += "</td>";
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

        function toggleTick(woId) {
            var wo = AssignWorkOrders.find(x => x.woId == woId);
            if (wo.competeQty === wo.totalQty) {

                $.ajax({
                    type: "POST",
                    url: "Packaging.aspx/UdpatePackagingStatus",
                    data: JSON.stringify({
                        detailedId: wo.woId
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        console.log(response);
                        window.location.reload();
                    },

                    error: function (xhr) {
                        console.log(xhr.responseText);
                        alert("Error calling method");
                    }
                });

                var tick = $("#status_" + woId);

                if (tick.hasClass("active")) {
                    tick.removeClass("active");
                    tick.css("color", "gray");
                } else {
                    tick.addClass("active");
                    tick.css("color", "green");
                }
            } else {
                alert('Please Pack the products first..');
            }

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
            html += "<th>Completed Qty</th>";
            html += "<th>Pack</th>";
            html += "<th>Image</th>";
            html += "</tr>";

            $.each(wo.details, function (i, item) {
                html += "<tr>";

                html += "<td>" + item.product + "</td>";
                html += "<td>" + item.size + "</td>";
                html += "<td>" + item.originalsqFeet + "</td>";
                html += "<td>" + item.originalQty + "</td>";
                html += "<td>" + item.allocatedQty + "</td>";

                html += "<td>";

                html += "<button type='button'  onclick='showMinusPanel(" + woId + "," + i + ")'>-</button>";
                html += " <span id='uq_" + woId + "_" + i + "'>" + item.usedQty + "</span> ";
                html += "<button type='button'  id='plus_" + woId + "_" + i + "' onclick='changeQty(" + woId + "," + i + ",1,false,false,\"No\")'>+</button>";
                html += "</td>";

                var image = item.imagename
                    ? item.imagename.replace("~/", "/Content/")
                    : 'https://placehold.co/400x400?text=Image';

                html += `<td>
                            <div class="image-hover-container">

                                <img src="${image}"
                                     class="product-image-preview"
                                     onclick="openImage('${image}')" />

                            </div>
                        </td>`;

                html += "</tr>";

                html += "<tr class='minusPanel' id='minusPanel_" + woId + "_" + i + "' style='display:none;background:#f8f9fa'>";
                html += "<td colspan='7' style='text-align:right;'>";

                html += "<div style='display:inline-block;padding:15px;border:1px solid #ccc;background:#9ab6dc;border-radius:6px;width:350px;text-align:left;'>";

                html += "<label style='margin-right:20px;color: red;'>";
                html += "<input style='border:1px solid red' type='checkbox' id='mistaken_" + woId + "_" + i + "' ";
                html += "onclick='selectReason(\"mistaken\"," + woId + "," + i + ")'> ";
                html += "Mistaken";
                html += "</label>";

                html += "<label style='color: red;'>";
                html += "<input style='border:1px solid red' type='checkbox' id='faulty_" + woId + "_" + i + "' ";
                html += "onclick='selectReason(\"faulty\"," + woId + "," + i + ")'> ";
                html += "Revert To Stage 1";
                html += "</label>";

                html += "<div id='reasonDiv_" + woId + "_" + i + "' style='display:none;margin-top:10px;'>";

                html += "<textarea id='reason_" + woId + "_" + i + "' ";
                html += "class='form-control' rows='3' ";
                html += "placeholder='Enter faulty reason'></textarea>";

                html += "</div>";

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

        function openImage(src) {
            $("#modalImg").attr("src", src);
            $("#imageModal").fadeIn();
        }
        $(document).on("click", "#imageModal", function () {
            $(this).fadeOut();
        });

        function selectReason(type, woId, index) {

            if (type === "mistaken") {

                $("#faulty_" + woId + "_" + index).prop("checked", false);
                $("#reasonDiv_" + woId + "_" + index).hide();
                $("#reason_" + woId + "_" + index).val("");

            } else {

                $("#mistaken_" + woId + "_" + index).prop("checked", false);

                if ($("#faulty_" + woId + "_" + index).is(":checked"))
                    $("#reasonDiv_" + woId + "_" + index).show();
                else
                    $("#reasonDiv_" + woId + "_" + index).hide();
            }
        }

        function confirmMinus(woId, index) {

            var mistaken = $("#mistaken_" + woId + "_" + index).is(":checked");
            var faulty = $("#faulty_" + woId + "_" + index).is(":checked");
            var reason = $("#reason_" + woId + "_" + index).val();

            if (!mistaken && !faulty) {
                alert("Select Mistaken or Faulty.");
                return;
            }

            if (faulty && reason.trim() == "") {
                alert("Please enter faulty reason.");
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
                faulty,
                reason
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
            var revertedSqFt = sqFtPerQty;

            $.ajax({
                type: "POST",
                url: "Packaging.aspx/SaveCompletedQty",
                data: JSON.stringify({
                    detailedId: item.detailedId,
                    completedQty: newQty,
                    completedSqFt: completedSqFt,
                    revertedSqFt: revertedSqFt,
                    mistaken: mistaken,
                    faulty: faulty,
                    reason: reason
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    debugger;
                    if (response.d.Status == "Success") {

                        item.usedQty = newQty;

                        $("#uq_" + woId + "_" + index).text(item.usedQty);

                        wo.competeQty = wo.details.reduce((t, d) => t + d.usedQty, 0);

                        $("#bal_" + woId).text(wo.competeQty);

                        if (response.d.IsCompleted) {
                            alert("Allocated Qty Completed.");
                        }


                        $("#mistaken_" + woId + "_" + index).prop("checked", false);
                        $("#faulty_" + woId + "_" + index).prop("checked", false);
                        $("#reason_" + woId + "_" + index).val("");
                        $("#reasonDiv_" + woId + "_" + index).hide();
                        $("#minusPanel_" + woId + "_" + index).hide();
                        $("#plus_" + woId + "_" + index).prop("disabled", false);

                        if (response.d.HeaderStatus === "Completed") {
                            window.location.href = window.location.href;
                        }
                        if (response.d.HeaderStatus === "Reverted") {
                            window.location.href = window.location.href;
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
                    <h3 class="m-0 font-weight-bold"><b>Packaging</b></h3>
                </div>
                <div class="card-body">
                    <div class="box">
                        <div id="woContainer"></div>
                        <div id="imageModal" class="image-popup">
                            <img id="modalImg" src="" />
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

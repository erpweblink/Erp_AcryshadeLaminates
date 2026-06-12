<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style type="text/css">
        /* From Uiverse.io by SachinKumar666 */
        .card {
            --card-bg: #ffffff;
            --card-accent: #7c3aed;
            --card-text: #1e293b;
            --card-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
            width: 235px;
            height: 245px;
            background: var(--card-bg);
            border-radius: 20px;
            position: relative;
            overflow: hidden;
            transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: var(--card-shadow);
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
        }

        .card__shine {
            position: absolute;
            inset: 0;
            background: linear-gradient( 120deg, rgba(255, 255, 255, 0) 40%, rgba(255, 255, 255, 0.8) 50%, rgba(255, 255, 255, 0) 60% );
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .card__glow {
            position: absolute;
            inset: -10px;
            background: radial-gradient( circle at 50% 0%, rgba(124, 58, 237, 0.3) 0%, rgba(124, 58, 237, 0) 70% );
            opacity: 0;
            transition: opacity 0.5s ease;
        }

        .card__content {
            padding: 1.25em;
            height: 100%;
            display: flex;
            flex-direction: column;
            gap: 0.75em;
            position: relative;
            z-index: 2;
        }

        .card__badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: #10b981;
            color: white;
            padding: 0.25em 0.5em;
            border-radius: 999px;
            font-size: 0.7em;
            font-weight: 600;
            transform: scale(0.8);
            opacity: 0;
            transition: all 0.4s ease 0.1s;
        }

        .card__image {
            width: 100%;
            height: 119px;
            background: linear-gradient(45deg, #a78bfa, #8b5cf6);
            border-radius: 12px;
            transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
        }

            .card__image::after {
                content: "";
                position: absolute;
                inset: 0;
                background: radial-gradient( circle at 30% 30%, rgba(255, 255, 255, 0.1) 0%, transparent 30% ), repeating-linear-gradient( 45deg, rgba(139, 92, 246, 0.1) 0px, rgba(139, 92, 246, 0.1) 2px, transparent 2px, transparent 4px );
                opacity: 0.5;
            }

        .card__text {
            display: flex;
            flex-direction: column;
            gap: 0.25em;
        }

        .card__title {
            color: var(--card-text);
            font-size: 1.1em;
            margin: 0;
            font-weight: 700;
            transition: all 0.3s ease;
        }

        .card__description {
            color: var(--card-text);
            font-size: 0.75em;
            margin: 0;
            opacity: 0.7;
            transition: all 0.3s ease;
        }

        /* Hover Effects */
        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border-color: rgba(124, 58, 237, 0.2);
        }

            .card:hover .card__shine {
                opacity: 1;
                animation: shine 3s infinite;
            }

            .card:hover .card__glow {
                opacity: 1;
            }

            .card:hover .card__badge {
                transform: scale(1);
                opacity: 1;
                z-index: 1;
            }

            .card:hover .card__image {
                transform: translateY(-5px) scale(1.03);
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            }

            .card:hover .card__title {
                color: var(--card-accent);
                transform: translateX(2px);
            }

            .card:hover .card__description {
                opacity: 1;
                transform: translateX(2px);
            }



        /* Active State */
        .card:active {
            transform: translateY(-5px) scale(0.98);
        }

        /* Animations */
        @keyframes shine {
            0% {
                background-position: -100% 0;
            }

            100% {
                background-position: 200% 0;
            }
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.2);
            }

            100% {
                transform: scale(1);
            }
        }

        @media (max-width: 576px) {
            .card {
                width: 95%;
                max-width: none;
                height: auto;
            }

            .card__content {
                padding: 15px;
            }

            .card__image {
                height: 100px;
            }

            .card__title {
                font-size: 1rem;
            }

            .card__description {
                font-size: 0.8rem;
            }
        }
    </style>
    <script type="text/javascript">
        $(document).on('click', '.dashboard-card', function () {

            var cardName = $(this).data('card');
            var count = $(this).find('h3').text().trim();

            if (parseInt(count) === 0) {
                return;
            }
            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetCardDetails",
                data: JSON.stringify({ cardName: cardName }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var data = response.d;

                    $('#callMeetingModal .modal-title').text(cardName + ' Details');

                    let table = $('#callMeetingTable');
                    table.empty();

                    if (!data || data.length === 0) {

                        table.html(`
                    <tbody>
                        <tr>
                            <td class="text-center">
                                No records found
                            </td>
                        </tr>
                    </tbody>
                `);

                        $('#callMeetingModal').modal('show');
                        return;
                    }

                    // Create Header
                    let columns = Object.keys(data[0]);

                    let thead = '<thead class="table-dark text-center"><tr>';

                    $.each(columns, function (i, col) {
                        thead += `<th style="color:whitesmoke">${col}</th>`;
                    });

                    thead += '</tr></thead>';

                    // Create Body
                    let tbody = '<tbody class="text-center">';

                    $.each(data, function (i, row) {

                        tbody += '<tr>';

                        $.each(columns, function (j, col) {
                            tbody += `<td>${row[col] ?? ''}</td>`;
                        });

                        tbody += '</tr>';
                    });

                    tbody += '</tbody>';

                    table.html(thead + tbody);

                    $('#callMeetingModal').modal('show');
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="container-fluid" id="divAdmin" runat="server">
                <div class="row justify-content-center">
                    <div class="col-md-3 d-flex justify-content-center">
                        <div class="card dashboard-card" data-card="Dealers">
                            <div class="card__shine"></div>
                            <div class="card__glow"></div>
                            <div class="card__content">
                                <div class="card__badge">Dealer</div>
                                <div style="--bg-color: #a78bfa" class="card__image">
                                    <p class="text-center" style="color: whitesmoke">No. of Dealers</p>
                                    <h3 id="lbldealerCount" runat="server" class="text-center" style="color: whitesmoke; font-weight: 900; font-size: 34px;"></h3>
                                </div>
                                <div class="card__text">
                                    <p class="card__title">Dealers</p>
                                    <p class="card__description">Represents the total count of active dealers within the distribution network.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex justify-content-center">
                        <div class="card dashboard-card" data-card="Stages">
                            <div class="card__shine"></div>
                            <div class="card__glow"></div>
                            <div class="card__content">
                                <div class="card__badge">Stage</div>
                                <div style="--bg-color: #a78bfa" class="card__image">
                                    <p class="text-center" style="color: whitesmoke">Total Stages</p>
                                    <h3 id="lblStages" runat="server" class="text-center" style="color: whitesmoke; font-weight: 900; font-size: 34px;"></h3>
                                </div>
                                <div class="card__text">
                                    <p class="card__title">Stages</p>
                                    <p class="card__description">Represents the total number of operational stages in the production workflow.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex justify-content-center">
                        <div class="card dashboard-card" data-card="Machines">
                            <div class="card__shine"></div>
                            <div class="card__glow"></div>
                            <div class="card__content">
                                <div class="card__badge">Machine</div>
                                <div style="--bg-color: #a78bfa" class="card__image">
                                    <p class="text-center" style="color: whitesmoke">Total Machines</p>
                                    <h3 id="lblMachines" runat="server" class="text-center" style="color: whitesmoke; font-weight: 900; font-size: 34px;"></h3>
                                </div>
                                <div class="card__text">
                                    <p class="card__title">Machines</p>
                                    <p class="card__description">Represents the total number of machines deployed across production facilities.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex justify-content-center">
                        <div class="card dashboard-card" data-card="Capacity">
                            <div class="card__shine"></div>
                            <div class="card__glow"></div>
                            <div class="card__content">
                                <div class="card__badge">Production</div>
                                <div style="--bg-color: #a78bfa" class="card__image">
                                    <p class="text-center" style="color: whitesmoke">Unit Capacity</p>
                                    <h3 id="lblCapacity" runat="server" class="text-center" style="color: whitesmoke; font-weight: 900; font-size: 34px;"></h3>
                                </div>
                                <div class="card__text">
                                    <p class="card__title">Production Capacity</p>
                                    <p class="card__description">Represents the maximum production output achievable per day.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <br />
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="shadow border-0">
                            <h5 class="text-white fw-bold"
                                style="background: linear-gradient(135deg, #4e73df, #224abe); padding: 4px 6px 4px 2px;">
                                <i class="fa fa-calendar-check me-2"></i>
                                Scheduled Work Orders
                            </h5>

                            <div class="p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover table-bordered mb-0 align-middle">
                                        <thead>
                                            <tr class="text-center">
                                                <th style="background-color: #6f42c1; color: white;">WO No</th>
                                                <th style="background-color: #20c997; color: white;">Customer</th>
                                                <th style="background-color: #fd7e14; color: white;">Product</th>
                                                <th style="background-color: #0dcaf0; color: white;">Quantity</th>
                                                <th style="background-color: #198754; color: white;">Start Date</th>
                                                <th style="background-color: #dc3545; color: white;">Due Date</th>
                                                <th style="background-color: #6c757d; color: white;">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td><strong>WO-1001</strong></td>
                                                <td>ABC Industries</td>
                                                <td>Wooden Sheet</td>
                                                <td class="text-center">50</td>
                                                <td>30-May-2026</td>
                                                <td>05-Jun-2026</td>
                                                <td>
                                                    <span class="badge bg-warning text-dark">In Progress
                                                    </span>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td><strong>WO-1002</strong></td>
                                                <td>XYZ Engineering</td>
                                                <td>HDMR Board</td>
                                                <td class="text-center">25</td>
                                                <td>01-Jun-2026</td>
                                                <td>10-Jun-2026</td>
                                                <td>
                                                    <span class="badge bg-success">Scheduled
                                                    </span>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td><strong>WO-1003</strong></td>
                                                <td>PQR Manufacturing</td>
                                                <td>Acrylic Sheet</td>
                                                <td class="text-center">15</td>
                                                <td>02-Jun-2026</td>
                                                <td>12-Jun-2026</td>
                                                <td>
                                                    <span class="badge bg-danger">Delayed
                                                    </span>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="callMeetingModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg modal-dialog-centered">
                        <div class="modal-content modelprofile1" style="background: linear-gradient(65deg, #4e83c5 0%, #d7deeff0 42%, #4976a359 100%);">

                            <!-- HEADER -->
                            <div class="modal-header headingcls d-flex align-items-center">
                                <h5 class="modal-title mb-0">Card Click Details
                                </h5>
                                <button type="button" class="btn-close ms-auto" data-bs-dismiss="modal"></button>
                            </div>

                            <div class="modal-body">
                                <div class="table-responsive">
                                    <table class="table table-bordered table-striped" id="callMeetingTable">
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

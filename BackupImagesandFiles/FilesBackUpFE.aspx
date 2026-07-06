<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="FilesBackUpFE.aspx.cs" Inherits="FilesBackUpFE" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style type="text/css">
        #fileContainer {
            min-height: 500px;
        }


        .file-card {
            cursor: pointer;
            transition: .25s;
            border-radius: 12px;
            height: 220px;
            overflow: hidden;
        }


            .file-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,.15);
            }


            .file-card img {
                height: 140px;
                object-fit: cover;
                width: 100%;
            }


        .file-icon {
            font-size: 70px;
            margin-top: 30px;
        }


        .file-name {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            font-weight: 600;
        }


        .file-size {
            font-size: 12px;
            color: #777;
        }


        .folder {
            color: #FFC107;
        }


        .pdf {
            color: #dc3545;
        }


        .word {
            color: #0d6efd;
        }


        .excel {
            color: #198754;
        }


        .image {
            color: #6f42c1;
        }



        #txtSearch {
            height: 45px;
        }


        .modal-content {
            border-radius: 15px;
        }


        .card-header {
            background: white;
        }


        /* ===== FULL SCREEN LOADER ===== */
        #pageLoader {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.6);
            backdrop-filter: blur(6px);
            z-index: 99999;
            justify-content: center;
            align-items: center;
        }

        /* ===== SPINNER ===== */
        .loader-ring {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 4px solid rgba(255,255,255,0.1);
            border-top: 4px solid #4f7cff;
            border-right: 4px solid #7c4dff;
            animation: spin 1s linear infinite;
            box-shadow: 0 0 25px rgba(79,124,255,0.6);
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        /* glow text */
        .loader-text {
            margin-top: 15px;
            color: #fff;
            font-weight: 600;
            letter-spacing: 1px;
            text-align: center;
            font-size: 14px;
            animation: pulse 1.2s infinite;
        }

        @keyframes pulse {
            0%,100% {
                opacity: 0.6;
            }

            50% {
                opacity: 1;
            }
        }
    </style>
    <script type="text/javascript">

        var currentPath = "";

        $(document).ready(function () {

            loadFiles("");

            $("#txtSearch").on("keyup", function () {

                var value = $(this).val().toLowerCase();

                $(".file-item").each(function () {

                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);

                });

            });

        });

        function loadFiles(path) {

            $("#fileContainer").html(
                '<div class="text-center mt-5">' +
                '<div class="spinner-border text-primary"></div>' +
                '</div>');

            $.ajax({

                type: "POST",

                url: "FilesBackUpFE.aspx/GetFiles",

                data: JSON.stringify({
                    path: path
                }),

                contentType: "application/json; charset=utf-8",

                dataType: "json",

                success: function (res) {

                    currentPath = path;

                    window.fileData = res.d;

                    buildCards(res.d);

                },

                error: function () {

                    alert("Unable to load files.");

                }

            });

        }

        function buildCards(data) {

            $("#fileContainer").empty();

            $.each(data, function (i, item) {

                var icon = "";

                if (item.IsFolder)
                    icon = '<i class="fa fa-folder fa-5x text-warning"></i>';

                else if (item.Extension == ".pdf")
                    icon = '<i class="fa fa-file-pdf fa-5x text-danger"></i>';

                else if (item.Extension == ".doc" || item.Extension == ".docx")
                    icon = '<i class="fa fa-file-word fa-5x text-primary"></i>';

                else if (item.Extension == ".xls" || item.Extension == ".xlsx")
                    icon = '<i class="fa fa-file-excel fa-5x text-success"></i>';

                var html = "";

                html += '<div class="col-lg-2 col-md-3 col-sm-4 col-6 mb-4 file-item">';

                html += '<div class="card shadow-sm file-card">';

                html += '<div class="card-body text-center">';

                if (item.IsImage) {

                    html += '<img src="' + item.RelativePath + '" class="img-fluid rounded" style="height:130px;width:100%;object-fit:cover;">';

                }
                else {

                    html += icon;

                }

                html += '<div class="mt-3 file-name">';

                html += item.Name;

                html += '</div>';

                html += '</div>';

                html += '</div>';

                html += '</div>';

                $("#fileContainer").append(html);

            });

            bindEvents();

        }

        function bindEvents() {

            $(".file-card").off("click");

            $(".file-card").on("click", function () {

                var index = $(this).closest(".file-item").index();

                var item = window.fileData[index];

                if (item.IsFolder) {

                    loadFiles(item.FullPath);

                    return;

                }

                preview(item);

            });

        }

        function preview(item) {

            if (item.IsImage) {

                $("#previewImage").attr("src", item.RelativePath);

                new bootstrap.Modal(document.getElementById("imageModal")).show();

                return;
            }

            if (item.Extension == ".pdf") {

                $("#pdfFrame").attr("src", item.RelativePath);

                new bootstrap.Modal(document.getElementById("pdfModal")).show();

                return;
            }

            window.open(item.RelativePath, "_blank");

        }

        $(document).on("click", "#btnBack", function (e) {

            e.preventDefault();

            $.ajax({

                type: "POST",
                url: "FilesBackUpFE.aspx/GetParent",
                data: JSON.stringify({ path: currentPath }),
                contentType: "application/json; charset=utf-8",

                success: function (res) {

                    loadFiles(res.d);

                },

                error: function () {

                    Swal.fire({
                        icon: "error",
                        title: "Unable to go back"
                    });

                }

            });

        });

        $(document).on("click", "#btnBackup", function (e) {

            e.preventDefault();

            Swal.fire({
                title: "Start Backup?",
                text: "Do you want to create a backup?",
                icon: "question",
                showCancelButton: true,
                confirmButtonText: "Yes, Backup",
                cancelButtonText: "Cancel"
            }).then((result) => {

                if (!result.isConfirmed)
                    return;

                validateAndShowLoader();

                $.ajax({
                    type: "POST",
                    url: "FilesBackUpFE.aspx/GetBackup",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {

                        $("#pageLoader").hide();

                        if (response.d) {

                            Swal.fire({
                                icon: "success",
                                title: "Backup Completed",
                                text: "Backup created successfully."
                            });

                        } else {

                            Swal.fire({
                                icon: "error",
                                title: "Backup Failed",
                                text: "Unable to create backup."
                            });

                        }

                    },

                    error: function (xhr) {

                        $("#pageLoader").hide();

                        Swal.fire({
                            icon: "error",
                            title: "Error",
                            text: xhr.responseText
                        });

                    }

                });

            });

        });

        $(document).on("click", "#btnRestore", function (e) {

            e.preventDefault();

            Swal.fire({
                title: "Restore Backup?",
                text: "Existing files may be replaced.",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, Restore"
            }).then((result) => {

                if (!result.isConfirmed)
                    return;

                validateAndShowLoader();

                $.ajax({

                    type: "POST",
                    url: "FilesBackUpFE.aspx/RestoreBackup",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",

                    success: function (response) {

                        Swal.fire({
                            icon: "success",
                            title: "Restore Completed",
                            text: response.d
                        });

                    },

                    error: function () {

                        $("#pageLoader").hide();

                        Swal.fire({
                            icon: "error",
                            title: "Restore Failed"
                        });

                    }

                });

            });

        });

        $(function () {

            $("#imageModal").on("hidden.bs.modal", function () {

                $("#previewImage").attr("src", "");
                loadFiles(currentPath);

            });

            $("#pdfModal").on("hidden.bs.modal", function () {

                $("#pdfFrame").attr("src", "");
                loadFiles(currentPath);

            });

        });

        function validateAndShowLoader() {
            // show loader only if valid
            document.getElementById("pageLoader").style.display = "flex";
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div id="pageLoader">
                <div style="text-align: center;">
                    <div class="loader-ring"></div>
                    <div class="loader-text">In-Process...</div>
                </div>
            </div>
            <div class="container-fluid mt-3">

                <!-- Header -->
                <div class="card shadow-sm border-0 mb-3">
                    <div class="card-body">

                        <div class="row align-items-center">

                            <div class="col-lg-4">
                                <h3 class="mb-0">
                                    <i class="fa fa-folder-open text-warning"></i>
                                    File Manager
                                </h3>
                            </div>

                            <div class="col-lg-4">

                                <div class="input-group">

                                    <span class="input-group-text">
                                        <i class="fa fa-search"></i>
                                    </span>

                                    <input type="text"
                                        id="txtSearch"
                                        class="form-control"
                                        placeholder="Search files..." />

                                </div>

                            </div>

                            <div class="col-lg-4 text-end">

                                <button type="button" id="btnBackup" class="btn btn-success">

                                    <i class="fa fa-download"></i>

                                    Get Backup

                                </button>

                                <button type="button" id="btnRestore"
                                    class="btn btn-primary">

                                    <i class="fa fa-upload"></i>

                                    Restore Backup

                                </button>

                            </div>

                        </div>

                    </div>
                </div>


          
                <!-- Back Button -->

                <div class="mb-3">

                    <button type="button"
                        class="btn btn-secondary"
                        id="btnBack">

                        <i class="fa fa-arrow-left"></i>

                        Back

                    </button>

                </div>



                <!-- Files -->

                <div class="row"
                    id="fileContainer">
                </div>

            </div>


            <!-- IMAGE MODAL -->

            <div class="modal fade"
                id="imageModal">

                <div class="modal-dialog modal-md modal-dialog-centered">

                    <div class="modal-content">

                        <div class="modal-header">

                            <h5>Image Preview

                            </h5>

                            <button
                                class="btn-close"
                                data-bs-dismiss="modal">
                            </button>

                        </div>

                        <div class="modal-body text-center">

                            <img
                                id="previewImage"
                                class="img-fluid rounded shadow" />

                        </div>

                    </div>

                </div>

            </div>



            <!-- PDF MODAL -->

            <div class="modal fade"
                id="pdfModal">

                <div class="modal-dialog modal-lg modal-dialog-centered">

                    <div class="modal-content">

                        <div class="modal-header">

                            <h5>PDF Preview

                            </h5>

                            <button
                                class="btn-close"
                                data-bs-dismiss="modal">
                            </button>

                        </div>

                        <div class="modal-body p-0">

                            <iframe
                                id="pdfFrame"
                                style="width: 100%; height: 80vh; border: none;"></iframe>

                        </div>

                    </div>

                </div>

            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

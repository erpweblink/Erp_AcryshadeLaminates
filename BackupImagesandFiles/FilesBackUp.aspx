<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" EnableEventValidation="false" AutoEventWireup="true" Async="true" CodeFile="FilesBackUp.aspx.cs" Inherits="FilesBackUp" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <style type="text/css">
        .card {
            border-radius: 10px;
            transition: .3s;
            cursor: pointer;
        }

            .card:hover {
                background: #f8f9fa;
                transform: scale(1.05);
            }

            .card div:last-child {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
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
        function validateAndShowLoader() {
            // show loader only if valid
            document.getElementById("pageLoader").style.display = "flex";
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server"></asp:ToolkitScriptManager>
    <div id="pageLoader">
        <div style="text-align: center;">
            <div class="loader-ring"></div>
            <div class="loader-text">In-Process...</div>
        </div>
    </div>
    <div class="container mt-3">
        <div class="text-center mt-5" id="divButtons" runat="server">

            <asp:Button ID="btnGetBackup"
                runat="server"
                Text="📥 Get Backup"
                CssClass="btn btn-success btn-lg mr-3"
                OnClick="btnGetBackup_Click"  OnClientClick="validateAndShowLoader()"/>

            <asp:Button ID="btnUploadBackup"
                runat="server"
                Text="📤 Upload Backup"
                CssClass="btn btn-primary btn-lg"
                OnClick="btnUploadBackup_Click" OnClientClick="validateAndShowLoader()"/>

        </div>

        <div id="divExplorer" runat="server">
            <div class="d-flex justify-content-between align-items-center mb-3">

                <h2 class="mb-0">
                    <asp:Label ID="lblPath" runat="server"></asp:Label>
                </h2>

                <asp:Button ID="btnBack"
                    runat="server"
                    Text="⬅ Back"
                    CssClass="btn btn-primary"
                    OnClick="btnBack_Click" />

            </div>

            <div class="row">

                <asp:Repeater ID="rptFiles" runat="server" OnItemCommand="rptFiles_ItemCommand">
                    <ItemTemplate>

                        <div class="col-md-2 col-sm-3 col-4 text-center mb-4">

                            <asp:LinkButton ID="lnkItem"
                                runat="server"
                                CssClass="text-decoration-none"
                                CommandName="Open"
                                CommandArgument='<%# Eval("FullPath") %>'>

                                <div class="card shadow-sm p-3">

                                    <asp:PlaceHolder ID="phImage" runat="server"
                                        Visible='<%# (bool)Eval("IsImage") %>'>

                                        <asp:Image ID="imgThumb"
                                            runat="server"
                                            ImageUrl='<%# ResolveUrl(Eval("RelativePath").ToString()) %>'
                                            Width="155"
                                            Height="170" />
                                    </asp:PlaceHolder>

                                    <asp:PlaceHolder ID="phIcon" runat="server"
                                        Visible='<%# !(bool)Eval("IsImage") %>'>

                                        <div style="font-size: 60px;">
                                            <%# Eval("IconText") %>
                                        </div>

                                    </asp:PlaceHolder>

                                    <div class="mt-2">
                                        <%# Eval("Name") %>
                                    </div>

                                </div>

                            </asp:LinkButton>

                        </div>

                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </div>
    </div>

</asp:Content>

<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/MasterPage.master" CodeFile="Alerts.aspx.cs" Inherits="Alerts" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="HDRContent" ContentPlaceHolderID="Head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.6.9/dist/sweetalert2.min.js"></script>

    <script type="text/javascript">    
        window.onload = function () {
            Swal.fire({
                icon: '<%= Session["icon"] %>',
                    text: '<%= Session["message"] %>',
                    showCancelButton: false,
                    showConfirmButton: false,
                    timer: '<%= Session["time"] %>',
                    timerProgressBar: true
                }).then(function () {
                    window.location.href = '<%= Session["url"] %>';
            });
        };
    </script>
</asp:Content>

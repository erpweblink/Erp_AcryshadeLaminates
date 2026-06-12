<%@ Page AutoEventWireup="true" Language="C#" CodeFile="AccessDenied.aspx.cs" Inherits="AccessDenied" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Designed for Acryshade Laminates Pvt. Ltd.">
    <title>Acryshade Laminates</title>
    <style>
        .container {
            text-align: center;
            background: #fff;
            padding: 50px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            max-width: 600px;
            width: 90%;
        }

        .error-code {
            font-size: 100px;
            font-weight: 700;
            color: #dc3545;
            line-height: 1;
        }

        .title {
            font-size: 32px;
            margin-top: 15px;
            color: #333;
            font-weight: 600;
        }

        .message {
            margin-top: 15px;
            color: #666;
            font-size: 18px;
            line-height: 1.6;
        }

        .icon {
            font-size: 70px;
            margin-bottom: 15px;
        }

        .btn-home {
            display: inline-block;
            margin-top: 30px;
            padding: 12px 30px;
            background: #0d6efd;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: 0.3s;
            font-size: 16px;
            font-weight: 500;
        }

            .btn-home:hover {
                background: #0b5ed7;
            }
    </style>
</head>
<body>
    <center>
        <div class="container">
            <div class="icon">🚫</div>

            <div class="error-code">403</div>

            <div class="title">Access Denied</div>

            <div class="message">
                You do not have permission to access this page.
            Please contact your administrator if you believe this is an error.
       
            </div>

            <a href="/Admin/Dashboard.aspx" class="btn-home">Back to Dashboard
        </a>
        </div>
    </center>
</body>
</html>

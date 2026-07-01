<%@ Page AutoEventWireup="true" Language="C#" CodeFile="AccessDenied.aspx.cs" Inherits="AccessDenied" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Access Denied Page - Acryshade Laminates Pvt. Ltd.">
       <link rel="icon" type="image/png" href="../Content/assets/images/CompanyLogo/CompLogo.jpg">
    <title>Access Denied</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #eef2f7, #dbe9ff);
            padding: 20px;
        }

        .container {
            text-align: center;
            background: #ffffff;
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.12);
            max-width: 500px;
            width: 100%;
            animation: fadeIn 0.5s ease-in-out;
        }

        .icon {
            font-size: 70px;
            margin-bottom: 10px;
            animation: bounce 1.5s infinite;
        }

        .error-code {
            font-size: 90px;
            font-weight: 800;
            color: #dc3545;
            line-height: 1;
        }

        .title {
            font-size: 28px;
            margin-top: 10px;
            color: #222;
            font-weight: 600;
        }

        .message {
            margin-top: 15px;
            color: #666;
            font-size: 16px;
            line-height: 1.6;
            padding: 0 10px;
        }

        .btn-home {
            display: inline-block;
            margin-top: 25px;
            padding: 12px 28px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(13, 110, 253, 0.25);
        }

        .btn-home:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(13, 110, 253, 0.35);
        }

        /* Animations */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        /* Mobile responsiveness */
        @media (max-width: 600px) {
            .container {
                padding: 35px 20px;
            }

            .error-code {
                font-size: 70px;
            }

            .title {
                font-size: 22px;
            }

            .message {
                font-size: 15px;
            }

            .icon {
                font-size: 55px;
            }
        }
    </style>
</head>

<body>

    <div class="container">
        <div class="icon">🚫</div>

        <div class="error-code">403</div>

        <div class="title">Access Denied</div>

        <div class="message">
            You do not have permission to access this page.<br />
            Please contact your administrator if you believe this is an error.
        </div>

        <a id="lblPdfUrl" runat="server" class="btn-home">Back to Dashboard</a>
    </div>

</body>
</html>
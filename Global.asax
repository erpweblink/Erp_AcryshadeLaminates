<%@ Application Language="C#" %>
<%@ Import Namespace="System.Timers" %>

<script RunAt="server">

    void Application_Start(object sender, EventArgs e)
    {
        //Class1 obj = new Class1();

        // System.Timers.Timer sessionTimer = new System.Timers.Timer();
        //// Set the Interval to 5 seconds (5000 milliseconds).
        //myTimer.Interval = 300000; // 5mins
        //myTimer.AutoReset = true;
        //myTimer.Elapsed += new ElapsedEventHandler(myTimer_Elapsed);
        //myTimer.Enabled = true; 
        //sessionTimer.Interval = 300000000; // 5 minutes in milliseconds
        //sessionTimer.Elapsed += new ElapsedEventHandler(KeepSessionAlive);
        //sessionTimer.AutoReset = true;
        //sessionTimer.Enabled = true;
    }

    public void myTimer_Elapsed(object source, System.Timers.ElapsedEventArgs e)
    {

    }

    void Application_End(object sender, EventArgs e)
    {
        //  Code that runs on application shutdown     
    }

    void Application_Error(object sender, EventArgs e)
    {
        // Code that runs when an unhandled error occurs
        //Exception exception = Server.GetLastError();
        //Server.ClearError();
        //string errorMessage = exception.InnerException.Message;
        //string encodedErrorMessage = Server.UrlEncode(errorMessage);
        //string currentPageUrl = Request.Url.AbsoluteUri;
        //string encodedCurrentPageUrl = Server.UrlEncode(currentPageUrl);
//Response.Redirect("~/Login.aspx");
       // Response.Redirect("~/Login.aspx?msg=" + encodedErrorMessage + "&url=" + encodedCurrentPageUrl);

    }

    public void KeepSessionAlive(object source, ElapsedEventArgs e)
    {
        // This method will interact with the session to keep it alive
        // Access the HttpContext and simulate session usage

        if (HttpContext.Current != null && HttpContext.Current.Session != null)
        {
            // Update or access a session variable to prevent timeout
          //  Session.Timeout = 120000;
           // HttpContext.Current.Session["KeepAlive"] = DateTime.Now;
        }
    }

    void Session_Start(object sender, EventArgs e)
    {
      //  HttpContext.Current.Session["KeepAlive"] = DateTime.Now;
        Session.Timeout = 1440;
        
        // Code that runs when a new session is started
        //if (Session["UserName"] == null)
        //{
        //    //Redirect to Welcome Page if Session is not null    
        //    Response.Redirect("Login.aspx");
        //}
    }

    void Session_End(object sender, EventArgs e)
    {

        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.
    }





</script>

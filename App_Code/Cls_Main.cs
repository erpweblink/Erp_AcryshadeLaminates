using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Summary description for Cls_Main
/// </summary>
public class Cls_Main
{
    public static string Conn_String = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

    public static SqlConnection Conn = new SqlConnection(Conn_String);

    private static SqlCommand Cmd;

    public static void Conn_Set()
    {
        Conn = new SqlConnection(Conn_String);
    }

    public static bool Conn_Open()
    {
        Conn_Set();
        try
        {
            if (Conn.State == System.Data.ConnectionState.Closed || Conn.State == System.Data.ConnectionState.Broken)
            {
                Conn.Open();
                return true;
            }
            else
            {
                return true;
            }
        }
        catch (Exception ex)
        {
            throw ex;//new ArgumentException("Server Is Not Connected Please Check Your Network Connection");
        }

    }

    public static void Conn_Close()
    {
        try
        {
            Conn.Close();
        }
        catch (Exception ex)
        {

            throw ex;
        }
    }

    public static void Conn_Dispose()
    {
        try
        {
            Conn.Dispose();
        }
        catch (Exception ex)
        {

            throw ex;
        }
    }

    public static DataTable Read_Table(string Query)
    {
        try
        {
            Conn_Open();
            DataTable Dt = new DataTable();
            Cmd = new SqlCommand(Query, Conn);
            Cmd.CommandTimeout = 0;
            SqlDataAdapter Da = new SqlDataAdapter(Cmd);
            Da.Fill(Dt);

            return Dt;

        }
        catch (Exception)
        {

            throw;
        }
        finally
        {
            Conn_Close();

        }

    }

    public static bool Check_Duplication(string Query)
    {
        try
        {
            Cmd = new SqlCommand(Query, Conn);
            SqlDataReader drd = Cmd.ExecuteReader();
            if (drd.Read())
            {
                drd.Close();
                return true;
            }
            else
            {
                drd.Close();
                return false;
            }
        }
        catch (Exception ex)
        {

            throw new ArgumentException(ex.Message);

        }
    }


}
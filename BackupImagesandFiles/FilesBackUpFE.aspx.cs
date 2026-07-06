using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class FilesBackUpFE : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString);
    CommonCls objcls = new CommonCls();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            string root = Server.MapPath("~/Content");
            ViewState["RootPath"] = root;
            ViewState["CurrentPath"] = root;
        }
    }


    [WebMethod]
    public static List<ExplorerItem> GetFiles(string path)
    {
        List<ExplorerItem> items = new List<ExplorerItem>();

        // If first time, load Content folder
        if (string.IsNullOrEmpty(path))
        {
            path = HttpContext.Current.Server.MapPath("~/Content");
        }

        DirectoryInfo dir = new DirectoryInfo(path);

        if (!dir.Exists)
            return items;

        // ===========================
        // FOLDERS
        // ===========================
        foreach (DirectoryInfo d in dir.GetDirectories())
        {
            if (d.Name.Equals("Assets", StringComparison.OrdinalIgnoreCase))
                continue;

            items.Add(new ExplorerItem
            {
                Name = d.Name,
                FullPath = d.FullName,
                RelativePath = "",
                IsFolder = true,
                IsImage = false,
                Extension = "",
                IconText = "📁"
            });
        }

        // ===========================
        // FILES
        // ===========================
        foreach (FileInfo f in dir.GetFiles())
        {
            bool isImage = false;
            string icon = "📄";

            switch (f.Extension.ToLower())
            {
                case ".jpg":
                case ".jpeg":
                case ".png":
                case ".gif":
                case ".bmp":
                case ".webp":
                    isImage = true;
                    break;

                case ".pdf":
                    icon = "📕";
                    break;

                case ".doc":
                case ".docx":
                    icon = "📘";
                    break;

                case ".xls":
                case ".xlsx":
                    icon = "📗";
                    break;
            }

            string relativePath = "/" +
                f.FullName
                .Replace(HttpContext.Current.Server.MapPath("~"), "")
                .Replace("\\", "/");

            items.Add(new ExplorerItem
            {
                Name = f.Name.Contains("_")
                        ? f.Name.Substring(f.Name.IndexOf('_') + 1)
                        : f.Name,

                FullPath = f.FullName,

                RelativePath = relativePath,

                IsFolder = false,

                IsImage = isImage,

                Extension = f.Extension.ToLower(),

                IconText = icon
            });
        }

        return items;
    }

    [WebMethod]
    public static string GetParent(string path)
    {
        string root = HttpContext.Current.Server.MapPath("~/Content");

        if (string.IsNullOrEmpty(path))
            return root;

        DirectoryInfo dir = new DirectoryInfo(path);

        if (!dir.Exists)
            return root;

        if (dir.FullName.Equals(root, StringComparison.OrdinalIgnoreCase))
            return root;

        if (dir.Parent == null)
            return root;

        if (dir.Parent.FullName.Length < root.Length)
            return root;

        return dir.Parent.FullName;
    }


    [WebMethod]
    public static bool GetBackup()
    {
        try
        {
            string rootFolder = HttpContext.Current.Server.MapPath("~/Content");

            SaveFolder(rootFolder);

            return true;
        }
        catch
        {
            return false;
        }
    }

    private static readonly string[] SkipFolders = { "assets" };
    private static void SaveFolder(string folder)
    {
        foreach (string dir in Directory.GetDirectories(folder))
        {
            string folderName = new DirectoryInfo(dir).Name;

            if (SkipFolders.Any(x => x.Equals(folderName, StringComparison.OrdinalIgnoreCase)))
                continue;

            SaveFolder(dir);
        }

        foreach (string file in Directory.GetFiles(folder))
        {
            SaveFile(file);
        }
    }

    private static void SaveFile(string filePath)
    {
        FileInfo file = new FileInfo(filePath);

        string relativePath = file.FullName.Replace(HttpContext.Current.Server.MapPath("~/"), "");

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
        {
            con.Open();

            // Check if already exists
            using (SqlCommand checkCmd = new SqlCommand(
                "SELECT COUNT(1) FROM tbl_FileBackup WHERE RelativePath=@RelativePath", con))
            {
                checkCmd.Parameters.AddWithValue("@RelativePath", relativePath);

                int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (exists > 0)
                    return;
            }

            byte[] fileBytes = File.ReadAllBytes(file.FullName);

            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.Connection = con;

                cmd.CommandText = @"
            INSERT INTO tbl_FileBackup
            (
                FolderName,
                FileName,
                FullFileName,
                RelativePath,
                Extension,
                FileSize,
                FileData
            )
            VALUES
            (
                @FolderName,
                @FileName,
                @FullFileName,
                @RelativePath,
                @Extension,
                @FileSize,
                @FileData
            )";

                cmd.Parameters.AddWithValue("@FolderName", file.Directory.Name);

                cmd.Parameters.AddWithValue("@FileName",
                    file.Name.Contains("_")
                    ? file.Name.Substring(file.Name.IndexOf('_') + 1)
                    : file.Name);

                cmd.Parameters.AddWithValue("@FullFileName", file.Name);

                cmd.Parameters.AddWithValue("@RelativePath", relativePath);

                cmd.Parameters.AddWithValue("@Extension", file.Extension);

                cmd.Parameters.AddWithValue("@FileSize", file.Length);

                cmd.Parameters.AddWithValue("@FileData", fileBytes);

                cmd.ExecuteNonQuery();
            }
        }
    }


    [WebMethod]
    public static string RestoreBackup()
    {
        try
        {
            int restoredCount = 0;

            string contentRoot = HttpContext.Current.Server.MapPath("~/Content");

            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["constr"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT RelativePath, FileData FROM tbl_FileBackup",
                    con);

                con.Open();

                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    string relativePath = dr["RelativePath"].ToString();

                    if (relativePath.StartsWith("Content\\"))
                        relativePath = relativePath.Substring(8);

                    if (relativePath.StartsWith("Content/"))
                        relativePath = relativePath.Substring(8);

                    byte[] bytes = (byte[])dr["FileData"];

                    string fullPath = Path.Combine(
                        contentRoot,
                        relativePath.Replace("/", "\\"));

                    string folder = Path.GetDirectoryName(fullPath);

                    if (!Directory.Exists(folder))
                        Directory.CreateDirectory(folder);

                    // Restore only if the file is missing
                    if (!File.Exists(fullPath))
                    {
                        File.WriteAllBytes(fullPath, bytes);
                        restoredCount++;
                    }
                }

                dr.Close();
            }

            return "Restore completed. "+restoredCount+" missing file(s) restored.";
        }
        catch (Exception ex)
        {
            return "Error: " + ex.Message;
        }
    }

    public class ExplorerItem
    {
        public string Name { get; set; }

        public string FullPath { get; set; }

        public string RelativePath { get; set; }

        public bool IsFolder { get; set; }

        public bool IsImage { get; set; }

        public string Extension { get; set; }

        public string IconText { get; set; }
    }
}



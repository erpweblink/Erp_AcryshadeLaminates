using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class FilesBackUp : System.Web.UI.Page
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

            LoadFolder(root);
        }
    }

    private void LoadFolder(string path)
    {
        string root = ViewState["RootPath"].ToString();

        btnBack.Visible = path != root;

        List<ExplorerItem> items = new List<ExplorerItem>();

        DirectoryInfo dir = new DirectoryInfo(path);

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
                IconText = "\U0001F4C1"
            });
        }

        foreach (FileInfo f in dir.GetFiles())
        {
            string ext = f.Extension.ToLower();

            bool isImage = false;
            string icon = "\U0001F4C4"; // 📄 Default File

            switch (ext.ToLower())
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
                    icon = "\U0001F4D5";   // 📕
                    break;

                case ".xls":
                case ".xlsx":
                    icon = "\U0001F4D7";   // 📗
                    break;

                case ".doc":
                case ".docx":
                    icon = "\U0001F4D8";   // 📘
                    break;

                case ".ppt":
                case ".pptx":
                    icon = "\U0001F4D9";   // 📙
                    break;

                case ".zip":
                case ".rar":
                    icon = "\U0001F5DC";   // 🗜
                    break;

                case ".mp4":
                case ".avi":
                case ".mov":
                case ".mkv":
                    icon = "\U0001F3A5";   // 🎥
                    break;

                case ".mp3":
                case ".wav":
                    icon = "\U0001F3B5";   // 🎵
                    break;
            }

            string relativePath = "/" + f.FullName
                 .Replace(Server.MapPath("~"), "")
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
                IconText = isImage ? "" : icon
            });
        }

        rptFiles.DataSource = items;
        rptFiles.DataBind();

        lblPath.Text = path.Replace(Server.MapPath("~/"), "");
    }

    protected void rptFiles_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        string path = e.CommandArgument.ToString();

        if (Directory.Exists(path))
        {
            ViewState["CurrentPath"] = path;
            LoadFolder(path);
        }
        else
        {
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("Content-Disposition",
                "attachment; filename=" + Path.GetFileName(path));

            Response.TransmitFile(path);
            Response.End();
        }
    }

    protected void btnBack_Click(object sender, EventArgs e)
    {
        string currentPath = ViewState["CurrentPath"].ToString();
        string rootPath = ViewState["RootPath"].ToString();

        if (currentPath == rootPath)
            return;

        DirectoryInfo dir = new DirectoryInfo(currentPath);
        string parent = dir.Parent.FullName;

        ViewState["CurrentPath"] = parent;

        LoadFolder(parent);
    }


    protected void btnGetBackup_Click(object sender, EventArgs e)
    {
        string rootFolder = Server.MapPath("~/Content");

        SaveFolder(rootFolder);

        ScriptManager.RegisterStartupScript(this, GetType(),
            "msg", "alert('Backup Completed Successfully'); window.location.href = window.location.href;", true);
    }

    private readonly string[] SkipFolders = { "Assets"};
    private void SaveFolder(string folder)
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

    private void SaveFile(string filePath)
    {
        FileInfo file = new FileInfo(filePath);

        string relativePath = file.FullName.Replace(Server.MapPath("~/"), "");

        // Check if file already exists
        using (SqlCommand checkCmd = new SqlCommand("SELECT COUNT(1) FROM tbl_FileBackup WHERE RelativePath=@RelativePath", con))
        {
            checkCmd.Parameters.AddWithValue("@RelativePath", relativePath);

            if (con.State == ConnectionState.Closed)
                con.Open();

            int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

            if (exists > 0)
            {
                con.Close();
                return; // Skip existing file
            }

            con.Close();
        }

        byte[] fileBytes = File.ReadAllBytes(file.FullName);

        using (SqlCommand cmd = new SqlCommand())
        {
            cmd.Connection = con;

            cmd.CommandText = @"INSERT INTO tbl_FileBackup
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

            if (con.State == ConnectionState.Closed)
                con.Open();

            cmd.ExecuteNonQuery();

            con.Close();
        }
    }

    protected void btnUploadBackup_Click(object sender, EventArgs e)
    {
        RestoreBackup();

        ScriptManager.RegisterStartupScript(this, GetType(),
            "msg", "alert('Backup Restored Successfully'); window.location.href = window.location.href;", true);
    }

    private void RestoreBackup()
    {
        string contentRoot = Server.MapPath("~/Content");

        using (SqlCommand cmd = new SqlCommand("SELECT RelativePath, FileData FROM tbl_FileBackup", con))
        {
            if (con.State == ConnectionState.Closed)
                con.Open();

            SqlDataReader dr = cmd.ExecuteReader();

            while (dr.Read())
            {
                string relativePath = dr["RelativePath"].ToString();

                // Remove "Content\" or "Content/" from the beginning
                if (relativePath.StartsWith("Content\\", StringComparison.OrdinalIgnoreCase))
                    relativePath = relativePath.Substring(8);

                if (relativePath.StartsWith("Content/", StringComparison.OrdinalIgnoreCase))
                    relativePath = relativePath.Substring(8);

                byte[] fileBytes = (byte[])dr["FileData"];

                string fullPath = Path.Combine(contentRoot,
                    relativePath.Replace("/", "\\"));

                string folder = Path.GetDirectoryName(fullPath);

                if (!Directory.Exists(folder))
                    Directory.CreateDirectory(folder);

                // Overwrite if file already exists
                File.WriteAllBytes(fullPath, fileBytes);
            }

            dr.Close();
            con.Close();
        }
    }

    public class ExplorerItem
    {
        public string Name { get; set; }
        public string FullPath { get; set; }
        public string RelativePath { get; set; }
        public bool IsFolder { get; set; }
        public string IconText { get; set; }
        public bool IsImage { get; set; }
    }
}



<%@ Import Namespace="System.IO" %>
<script runat="SERVER" language="C#">
    /*
     *  SIMPLE FILE BROWSER
     * 
     *  by Gibson
     *  Est. 2017
     * 
     *  Feel free to use and modify it. Please keep this header adding your name.
     */

    //TODO: handle layout in HTML markup
    private const string header = "<thead><tr><th class='text-center'>Name</th><th class='text-center' style='width: 20%;'>Size (KB)</th><th class='text-center' style='width: 20%;'>Date modified</th></tr></thead>";
    private const string line = "<tr><td class='text-left'>{0}</td><td class='text-right'>{1}</td><td class='text-right'>{2}</td></tr>";
    // Font-awesome icons
    //private const string backLink = "<a class=\"text-muted\" href=\"?path={0}/\"><i class=\"fa fa-level-up fa-flip-horizontal\" aria-hidden=\"true\"></i> Back</a>";
    //private const string dirLink = "<a class=\"text-info\" href=\"?path={1}{0}/\"><i class=\"fa fa-folder\" aria-hidden=\"true\"></i> {0}</a>";
    //private const string fileLink = "<a href=\"?file={1}{0}\"><i class=\"fa fa-file\" aria-hidden=\"true\"></i> {0}</a>";
    // Bootstrap icons
    private const string backLink = "<a class=\"text-muted\" href=\"?path={0}/\"><span class=\"glyphicon glyphicon-level-up\" aria-hidden=\"true\"></span> Back</a>";
    private const string dirLink = "<a class=\"text-info\" href=\"?path={1}{0}/\"><span class=\"glyphicon glyphicon-folder-close\" aria-hidden=\"true\"></span> {0}</a>";
    private const string fileLink = "<a href=\"?file={1}{0}\"><span class=\"glyphicon glyphicon-file\" aria-hidden=\"true\"></span> {0}</a>";

    private const string defaultBasePath = null;

    private string basePath = defaultBasePath;
    /// <summary>
    /// Starting browser path.
    /// </summary>
    public string BasePath
    {
        get { return basePath; }
        set { basePath = value; }
    }

    /// <summary>
    /// Comma separated visible roots list 
    /// </summary>
    private string allowedRoots = "";
    public string AllowedRoots
    {
        get { return allowedRoots; }
        set { allowedRoots = value; }
    }

    /// <summary>
    /// Comma separated invisible file list 
    /// </summary>
    private string filterSecurity = "*.asp;*.aspx;*.ascx;*.php";
    public string FilterSecurity
    {
        get { return filterSecurity; }
        set { filterSecurity = value; }
    }

    /// <summary>
    /// Comma separated invisible file list 
    /// </summary>
    private string filterOut = "";
    public string FilterOut
    {
        get { return filterOut; }
        set { filterOut = value; }
    }

    /// <summary>
    /// Comma separated invisible file list 
    /// </summary>
    private string filterIn = "";
    public string FilterIn
    {
        get { return filterIn; }
        set { filterIn = value; }
    }

    void Page_Load() {
        // Requested browsing path
        string path = Request["path"];
        if (string.IsNullOrEmpty(path)) {
            path = "/";
        }
        // Requested file
        string file = Request["file"];
        // Transmit file to client.
        if (!string.IsNullOrEmpty(file)) {
            Response.Buffer = false; //transmitfile self buffers
            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            //TODO: customize content type based on file type.
            //Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + System.IO.Path.GetFileName(file));
            Response.TransmitFile(mapPath(file)); //transmitfile keeps entire file from loading into memory
            Response.End();
            return;
        }


        // Cleaning dungerous requests.
        path = path.Replace("..", String.Empty).Replace("./", "/").Replace("\\", "/").Trim();

        DirectoryInfo dir = new DirectoryInfo(mapPath(path));

        directories.Text = header + "<tbody>";
        // Adding Back button
        if (path != "/") {
            string prevPath = path.TrimEnd('/');
            if (prevPath.Length > 0) {
                prevPath = prevPath.Substring(0, prevPath.LastIndexOf('/'));
            }
            directories.Text += string.Format(line, String.Format(backLink, prevPath), null, null);
        }

        // Directory list.
        foreach (DirectoryInfo localDir in dir.GetDirectories()) {
            bool skip = false;
            if (!string.IsNullOrEmpty(AllowedRoots)) {
                skip = true;
                foreach (string filter in AllowedRoots.Split(';')) {
                    // Double check to manage subdirs
                    if (filter.ToLower().ToLower().StartsWith((path + localDir.Name).ToLower()) || (path + localDir.Name).ToLower().StartsWith(filter.ToLower())) {
                        skip = false;
                        break;
                    }
                }
            }
            if (skip) continue;
            directories.Text += string.Format(line, String.Format(dirLink, localDir.Name, path), null, null);
        }

        // File list
        foreach (FileInfo localFile in dir.GetFiles()) {
            bool skip = false;
            if (!string.IsNullOrEmpty(FilterIn)) {
                skip = true;
                foreach (string filter in FilterIn.Split(';')) {
                    if (fits(localFile.Name, filter)) {
                        skip = false;
                        break;
                    }
                }
            }
            if (skip) continue;

            if (!string.IsNullOrEmpty(FilterSecurity)) {
                foreach (string filter in FilterSecurity.Split(';')) {
                    if (fits(localFile.Name, filter)) {
                        skip = true;
                        break;
                    }
                }
            }
            if (skip) continue;

            if (!string.IsNullOrEmpty(FilterOut)) {
                foreach (string filter in FilterOut.Split(';')) {
                    if (fits(localFile.Name, filter)) {
                        skip = true;
                        break;
                    }
                }
            }
            if (skip) continue;

            files.Text += string.Format(line, String.Format(fileLink, localFile.Name, path), localFile.Length / 1024, localFile.LastWriteTime.ToShortDateString());
        }
        files.Text += "</tbody>";
    }

    /// <summary>
    /// Maps requested path to local path.
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    private string mapPath(string path) {
        if (string.IsNullOrEmpty(basePath)) {
            return Server.MapPath(path);
        } else {
            return basePath + path;
        }
    }

    //https://stackoverflow.com/a/19655824
    private bool fits(string sFileName, string sFileMask) {
        String convertedMask = "^" + Regex.Escape(sFileMask).Replace("\\*", ".*").Replace("\\?", ".") + "$";
        Regex regexMask = new Regex(convertedMask, RegexOptions.IgnoreCase);
        return regexMask.IsMatch(sFileName);
    }

</script>
<table class="table table-striped table-hover table-condensed">
    <asp:Literal ID="directories" runat="server" />
    <asp:Literal ID="files" runat="server" />
</table>

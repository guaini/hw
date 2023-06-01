<%@ page language="java"
         import="java.io.*, java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.json.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>


<%@ page contentType="text/html;charset=UTF-8" %>

<%!

    public String getPostData(InputStream in, int size) throws IOException {
        byte buf[] = new byte[size];
        in.read(buf);
        return new String(buf);
    }

    public void sendJsonData(String jsonStr, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.getWriter().write(jsonStr);
        response.getWriter().flush();
    }

%>

<%
    Statement conn = null;
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection(connectString,
                "user", "123");
        conn = con.createStatement();
    } catch (Exception e) {
        e.printStackTrace();
    }
    Statement template = conn;

    if (request.getHeader("Authorization") == null) {
        String res = "{\"ret\": 1, \"msg\":\"未登录\"}";
        sendJsonData(res, response);
        response.getWriter().close();
    } else {
        if (!ServletFileUpload.isMultipartContent(request)) {
            throw new Exception("not file upload...");
        }

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setHeaderEncoding("UTF-8");

        List<FileItem> formItems = upload.parseRequest(request);
        String action = null;
        String postData = null;
        FileItem file = null;

        if (formItems != null && formItems.size() > 0) {
            // out.print(formItems.size());
            for (FileItem item : formItems) {
                if (!item.isFormField()) {
                    file = item;
                } else {
                    if ("action".equals(item.getFieldName())) {
                        action = item.getString();
                    } else if ("data".equals(item.getFieldName())) {
                        postData = item.getString();
                    }
                }
            }
        }
        if (file == null || action == null || postData == null) {
            throw new Exception("lost parameters...");
        }
        if (action.equals("upload")) {
            JSONObject jsondata = JSONObject.fromObject(postData);
            String filename = jsondata.getString("name");
            if (!filename.contains(".")) {
                String[] stemp = file.getName().split("\\.");
                String suffix = stemp[stemp.length - 1];
                filename += "." + suffix;
            }
            String uploadPath = "upload" + File.separator + filename;
            // String prefix = "." + request.getContextPath();
            String prefix = request.getSession().getServletContext().getRealPath("");
            File sfile = new File(prefix + File.separator + "imgs" + File.separator + uploadPath);
            file.write(sfile);
            // warning: not get the user... to insert the uploader
            String token = request.getHeader("Authorization");
            Date time = new java.sql.Timestamp(new java.util.Date().getTime());
            String sql = "select UID from t_user where nickname='" + token + "'";
            ResultSet rs = conn.executeQuery(sql);
            int uid = 0;
            if (rs.next()) {
                uid = rs.getInt("UID");
            }
            sql = "insert into t_image(pname, URL, uploader, upload_time) VALUES('" + filename + "','" + uploadPath.replace("\\", "/") + "','" + uid + "','" + time + "')";
            try {
                conn.execute(sql);
            } catch (Exception e) {
                out.print(e);
            }
            Object[] tag_list = jsondata.getJSONArray("tags").toArray();
            sql = "select PID from t_image where URL='" + uploadPath.replace("\\", "/") + "'";
            rs = conn.executeQuery(sql);
            int pid = 0;
            if (rs.next()) {
                pid = rs.getInt("PID");
            }
            for (Object object : tag_list) {
                String tag_name = object.toString();
                String query = "select TID from t_tag where tname='" + tag_name + "'";
                rs = conn.executeQuery(query);
                int tid = 0;
                if (!rs.next()) {
                    query = "insert into t_tag(tname) VALUES('" + tag_name + "')";
                    conn.execute(query);
                    query = "select TID from t_tag where tname='" + tag_name + "'";
                    rs = conn.executeQuery(query);
                    rs.next();
                }
                tid = rs.getInt("TID");
                query = "insert into t_pic_to_tag(PID, TID) VALUES('" + pid + "','" + tid + "')";
                conn.executeUpdate(query);
            }
            String res = "{\"msg\": \"上传成功\"}";
            sendJsonData(res, response);
            response.getWriter().close();
        } else {
            throw new Exception("unknow operator for " + action);
        }
    }


%>


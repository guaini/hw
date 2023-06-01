<%@ page language="java"
         import="java.io.*, java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.json.*" %>


<%@ page contentType="text/html;charset=UTF-8" %>

<%!

    public String getPostData(InputStream in, int size) throws IOException {
        byte[] buf = new byte[size];
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

    String postData = getPostData(request.getInputStream(), request.getContentLength());
    JSONObject jsonData = JSONObject.fromObject(postData);
    String action = jsonData.getString("action");
    try {
        String sql = "";
        if ("list".equals(action)) {
            sql = "select * from t_image";
            ResultSet rs = conn.executeQuery(sql);
            StringBuilder res = new StringBuilder("{\"ret\":0, \"picList\":[");
            String sep = "";
            while (rs.next()) {
                String pid = rs.getString("PID");
                String pname = rs.getString("pname");
                String uploader = rs.getString("uploader");
                String url = rs.getString("URL");
                String date = rs.getString("upload_time");
                String width = "960"; //= rs.getString("");
                String height = "640"; // = rs.getString("");
                String o = "{\"pid\":\"" + pid + "\", \"pname\":\"" + pname + "\", \"upload_time\":\"" + date + "\", \"uploader\":\"" + uploader + "\", \"url\":\"" + url + "\",\"width\":" + width + ",\"height\":" + height + "}";
                res.append(sep).append(o);
                sep = ",";
            }
            res.append("]}");
            sendJsonData(res.toString(), response);
            response.getWriter().close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print(e.toString() + "login failed" + request.getParameter("username") + request.getParameter("password"));
    }
%>


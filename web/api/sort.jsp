<%--
  Created by IntelliJ IDEA.
  User: 123
  Date: 2023/6/7
  Time: 23:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page language="java"
         import="java.io.*, java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.json.*" %>
<%@ page import="java.util.logging.SimpleFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>


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

    String action;
    if (request.getMethod().equals("GET")) {
        action = request.getParameter("action");
    } else {
        String postData = getPostData(request.getInputStream(), request.getContentLength());
        JSONObject jsonData = JSONObject.fromObject(postData);
        action = jsonData.getString("action");
    }

    try {
        String sql = "select * from t_image order by";
        if ("date".equals(action)) {
            sql += " upload_time DESC";
        } else if ("pid".equals(action)) {
            sql += " PID ASC";
        } else if ("star".equals(action)) {
            sql += " num_star DESC";
        } else if ("like".equals(action)) {
            sql += " num_like DESC";
        } else if ("name".equals(action)) {
            sql += " pname ASC";
        }
        ResultSet rs = conn.executeQuery(sql);
        StringBuilder res = new StringBuilder("{\"ret\":0, \"picList\":[");
        String sep = "";
        while (rs.next()) {
            String pid = rs.getString("PID");
            String pname = rs.getString("pname");
            String uploader = rs.getString("uploader");
            String url = rs.getString("URL");
            String upload_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getDate("upload_time"));
            String width = "960"; //= rs.getString("");
            String height = "640"; // = rs.getString("");
            String o = "{\"pid\":\"" + pid + "\", \"pname\":\"" + pname + "\", \"upload_time\":\"" + upload_time + "\", \"uploader\":\"" + uploader + "\", \"url\":\"" + url + "\",\"width\":" + width + ",\"height\":" + height + "}";
            res.append(sep).append(o);
            sep = ",";
        }
        res.append("]}");
        sendJsonData(res.toString(), response);
        response.getWriter().close();
    } catch (Exception e) {
        e.printStackTrace();
        out.print(e.toString() + "login failed" + request.getParameter("username") + request.getParameter("password"));
    }
%>

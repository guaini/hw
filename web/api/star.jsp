<%@ page language="java"
         import="java.io.*,javax.sql.*, javax.naming.*,java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
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
    Statement conn2 = null;
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection(connectString,
                "user", "123");
        conn = con.createStatement();
        conn2 = con.createStatement();
    } catch (Exception e) {
        e.printStackTrace();
    }
    Statement template = conn;
    String token = request.getHeader("Authorization");
    String action = request.getParameter("action");

    try {
        StringBuilder res = null;
        String sql = "";
        boolean login = true;
        if (request.getHeader("Authorization") == null) {
            res = new StringBuilder("{\"ret\": 1, \"msg\":\"未登录\"}");
            login = false;
        }
        sql = "select UID from t_user where nickname='" + token + "'";
        ResultSet rs = conn.executeQuery(sql);
        int uid = 0;
        if (rs.next()) {
            uid = rs.getInt("UID");
        }
        if (action.equals("upload_list")) {
            sql = "select * from t_image where uploader = '" + uid + "'";
        } else if (action.equals("favor_list")) {
            sql = "select * from t_image,t_favorite where t_image.PID = t_favorite.PID and user = '" + uid + "'";
        }
        if (login) {
            rs = conn2.executeQuery(sql);
            res = new StringBuilder("{\"ret\":0, \"picList\":[");
            String sep = "";
            while (rs.next()) {
                String pid = rs.getString("PID");
                String name = rs.getString("pname");
                String url = rs.getString("URL");
                String date = rs.getString("upload_time");
                String uploader = rs.getString("uploader");
                if (action.equals("check_upload") && uploader.equals(token)) {
                    res = new StringBuilder("{\"ret\":0, \"picList\":[");
                }
                String upload_time = rs.getString("upload_time");
                int num_like = rs.getInt("num_like");
                int num_star = rs.getInt("num_star");
                int num_view = rs.getInt("num_view");
                String width = "960"; //= rs.getString("");
                String height = "640"; // = rs.getString("");
                String o = "{\"url\":\"" + url + "\",\"pid\":" + pid + ",\"pname\":\"" + name + "\", \"upload_time\":\"" + date + "\",\"width\":" + width + ",\"height\":" + height + ",\"uploader\":" + uploader + ",\"num_like\":" + num_like + ",\"num_star\":" + num_star + ",\"num_view\":" + num_view + ",\"name\":\"" + name + "\",\"msg\":\"" + "收藏成功!\"}" ;
                res.append(sep).append(o);
                sep = ",";
            }
            res.append("]}");
        }
        sendJsonData(res.toString(), response);
        response.getWriter().close();
    } catch (Exception e) {
        e.printStackTrace();
        out.print(e.toString());
    }


%>
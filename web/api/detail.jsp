<%@ page language="java"
         import="java.io.*,javax.sql.*, javax.naming.*,java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
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
    String token = request.getHeader("Authorization");
    String action;
    String pid;
    if (request.getMethod().equals("GET")) {
        action = request.getParameter("action");
        pid = request.getParameter("pid");
    }
    else {
        String postData = getPostData(request.getInputStream(), request.getContentLength());
        JSONObject jsonData = JSONObject.fromObject(postData);
        action = jsonData.getString("action");
        pid = jsonData.getString("pid");
    }



    try {
        String res = "{\"ret\": 1}";
        boolean login = true;
        if (request.getHeader("Authorization") == null) {
            res = "{\"ret\": 1, \"msg\":\"未登录\"}";
            login = false;
        }
        if (action.equals("pic_info")) {
            String sql = "select * from t_image where pid = '" + pid + "'";
            ResultSet rs = conn.executeQuery(sql);
            if (rs.next()) {
                String name = rs.getString("pname");
                String url = rs.getString("URL");
                String uploader = rs.getString("uploader");
                String upload_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getDate("upload_time"));
                int num_like = rs.getInt("num_like");
                int num_star = rs.getInt("num_star");
                int num_view = rs.getInt("num_view");
                String width = "960"; //= rs.getString("");
                String height = "640"; // = rs.getString("");
                String info = "{\"url\":\"" + url + "\",\"pid\":" + pid
                        + ",\"pname\":\"" + name + "\",\"width\":" + width + ",\"height\":" + height
                        + ",\"uploader\":" + uploader + ",\"upload_time\":\"" + upload_time
                        + "\",\"num_like\":" + num_like + ",\"num_star\":" + num_star
                        + ",\"num_view\":" + num_view + ",\"name\":\"" + name + "\"}";
                res = "{\"ret\":0, \"info\":" + info + "}";
            }
        } else if (login && action.equals("check_upload")) {
            String sql = "select uploader from t_image where PID = '" + pid + "'";
            ResultSet rs = conn.executeQuery(sql);
            if (rs.next()) {
                int uid = rs.getInt("uploader");
                sql = "select nickname from t_user where UID='" + uid + "'";
                rs = conn.executeQuery(sql);
                if (rs.next()) {
                    String name = rs.getString("nickname");
                    if (name.equals(token))
                        res = "{\"ret\": 0}";
                    else
                        res = "{\"ret\": 1}";
                }
            }
        } else if (login && action.equals("delete")) {
            String sql = "delete from t_image where PID = " + pid;
            if (conn != null) {
                conn.execute(sql);
            }
            res = "{\"ret\": 0, \"msg\":\"删除成功\"}";
        }
        sendJsonData(res, response);
        response.getWriter().close();
    } catch (Exception e) {
        e.printStackTrace();
        out.print(e.toString());
    }


%>
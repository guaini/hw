<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    Statement conn = null;
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    StringBuilder table = new StringBuilder();
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection(connectString,
                "user", "123");
        conn = con.createStatement();
    } catch (Exception e) {
        e.printStackTrace();
    }
    PrintWriter output = response.getWriter();
    Statement template = conn;
    try {
        if (request.getParameter("reg") != null) {
            String query = "select * from t_user where nickname='" + request.getParameter("username") + "'";
            ResultSet rs = null;
            if (conn != null) {
                rs = conn.executeQuery(query);
            }
            if (rs != null && rs.next())
            {
                output.print("username already exist.\nregister failed.\nusername: " + request.getParameter("username") + ", password: " + request.getParameter("password"));
            }
            else
            {
                //定义sql
                String sql = "insert into t_user(nickname,passwd) values('" + request.getParameter("username") + "','" + request.getParameter("password") + "')";
                //执行sql
                if (template != null) {
                    int update = template.executeUpdate(sql);
                }
                request.setAttribute("state", "success");
                session.setAttribute("username", request.getParameter("username"));
                session.setAttribute("password", request.getParameter("password"));
                output.print("register successful.\nusername: " + request.getParameter("username") + "password: " + request.getParameter("password"));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        output.print(e.toString() + "\nregister failed.\nusername: " + request.getParameter("username") + "password: " + request.getParameter("password"));
    }
    try {
        if (request.getParameter("login") != null) {
            //定义sql
            String sql = "select * from t_user where nickname='" + request.getParameter("username") + "' and passwd='" + request.getParameter("password") + "'";
            //执行sql
            ResultSet rs = null;
            if (conn != null) {
                rs = conn.executeQuery(sql);
            }
            if (rs != null && rs.next()) {
                session.setAttribute("id", rs.getString("UID"));
                session.setAttribute("user", request.getParameter("username"));
                session.setAttribute("password", request.getParameter("password"));
                output.print(rs.getString("UID"));
            }
            else {
                output.print("login failed");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        output.print(e.toString() + "\nlogin failed.\nusername: " + request.getParameter("username") + "password: " + request.getParameter("password"));
    }
    output.flush();
    output.close();
%>


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

    Statement template = conn;
    try {
        if (request.getParameter("reg") != null) {
            //定义sql
            String sql = "insert into t_user values(" + request.getParameter("username") + ",'','','2000-01-01','MALE','','" + request.getParameter("password") + "')";
            //执行sql
            if (template != null) {
                int update = template.executeUpdate(sql);
            }
            request.setAttribute("state", "注册成功");
            request.getSession().setAttribute("username", request.getParameter("username"));
            request.getSession().setAttribute("password", request.getParameter("password"));
            PrintWriter output = response.getWriter();
            output.print("register successful");
            output.flush();
            output.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        PrintWriter output = response.getWriter();
        output.print("register failed");
        output.flush();
        output.close();
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
                request.setAttribute("state", "login success");
                request.setAttribute("user", request.getParameter("username"));
                request.setAttribute("password", request.getParameter("password"));
                request.getRequestDispatcher("index.html").forward(request, response);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        PrintWriter output = response.getWriter();
        output.print(e.toString() + "login failed" + request.getParameter("username") + request.getParameter("password"));
    }
%>



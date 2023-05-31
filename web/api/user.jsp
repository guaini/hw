<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.*" %>
<%@ page import="net.sf.json.*" %>


<%@ page contentType="text/html;charset=UTF-8" %>
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

    String action = request.getParameter("action");
    action = "login";
    try {
        if("login".equals(action)) {
	    String username = request.getParameter("username");
	    String password = request.getParameter("password");
	    username = "helloworld";
	    password = "hello";
            //定义sql
            String sql ="select * from t_user where nickname='"+username+"' and passwd='"+password+"'";
            //执行sql
            ResultSet rs = conn.executeQuery(sql);
	    String res = "";
            if(rs.next()) {
		res = "{\"ret\": 0, \"msg\":\"登录成功\", \"token\": \"token123213123\"}";
	    } else {
		res = "{\"ret\": 1, \"msg\":\"账号或秘码错误\"}";
	    }
	    response.setCharacterEncoding("UTF-8");
	    response.setContentType("application/json");
	    response.getWriter().write(res);
	    response.getWriter().flush();
	    response.getWriter().close();
        }
	
    } catch (Exception e) {
        e.printStackTrace();
        output.print(e.toString() + "login failed" + request.getParameter("username") + request.getParameter("password"));
    }
%>


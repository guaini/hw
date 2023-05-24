
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<!DOCTYPE html>
<html lang="en">
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Statement conn = null;
    String connectString = "jdbc:mysql://localhost:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    StringBuilder table=new StringBuilder("");
    try{
        Class.forName("com.mysql.jdbc.Driver");
        Connection con= DriverManager.getConnection(connectString,
                "user", "123");
        Statement stmt=con.createStatement();
        conn = stmt;
    } catch (Exception e){
	out.print(e);
    }

    Statement template = conn;

    String action = request.getParameter("action");

    try {
        if("login".equals(action)) {
            //定义sql
            String sql ="select * from t_user where nickname='"+request.getParameter("username")+"' and passwd='"+request.getParameter("password")+"'";
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
        out.print(e.toString()+"login failed "+request.getParameter("username")+request.getParameter("password"));
    }
%>


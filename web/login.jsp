<%--
  Created by IntelliJ IDEA.
  User: 123
  Date: 2023/5/23
  Time: 21:10
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="java.util.*,java.sql.*" contentType="text/html; charset=utf-8"%>
<%
    request.setCharacterEncoding("utf-8");
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    try
    {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(connectString, "user", "123");
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(String.format("select * from t_user where nickname='%s'", username));
        if (rs.next())
        {
            String pwd = rs.getString("passwd");
            if (!Objects.equals(pwd, password)) {
                Cookie cookie = new Cookie("user", username);
                cookie.setMaxAge(3600 * 12);
                response.addCookie(cookie);
            }
            else {
                response.sendError(202, "登录失败");
            }
        }
        stmt.close();
        conn.close();
    }
    catch (Exception e)
    {
        response.sendError(202, e.getMessage());
    }
%>
<html>
<head>
    <title>Title</title>
</head>
<body>

</body>
</html>

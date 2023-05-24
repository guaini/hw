<%--
  Created by IntelliJ IDEA.
  User: cwy
  Date: 2023/5/23
  Time: 19:38
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html" language="java" import="java.sql.*" %>
<%
    request.setCharacterEncoding("utf-8");
    String msg ="";
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    StringBuilder table=new StringBuilder("");
    try{
        Class.forName("com.mysql.jdbc.Driver");
        Connection con=DriverManager.getConnection(connectString,
                "user", "123");
        Statement stmt=con.createStatement();
        ResultSet rs=stmt.executeQuery("select * from t_user where UID='"+username+"' and password='"+password+"'");
        if(rs.getRow()==0) {
            out.print("null answer");
        }
        rs.close();
        stmt.close();
        con.close();
    }
    catch (Exception e){
        out.print(e);
        msg = e.getMessage();
    }
%>
<%response.setHeader("Refresh","5;URL=index.html");%>
<html>
<head>
    <meta http-equiv="refresh" content="0;url=index.html">
    <title>Title</title>
</head>
<body>
</body>
</html>

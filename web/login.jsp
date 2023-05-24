<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.io.PrintWriter" %>
<!DOCTYPE html>
<html lang="en">
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    Statement conn = null;
    String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
            + "?autoReconnect=true&useUnicode=true"
            + "&characterEncoding=UTF-8";
    StringBuilder table = new StringBuilder();
    try{
        Class.forName("com.mysql.jdbc.Driver");
        Connection con= DriverManager.getConnection(connectString,
                "user", "123");
        conn = con.createStatement();
    }
    catch (Exception ignored) {}

    Statement template = conn;
    try {
        if(request.getParameter("reg")!=null){
            //定义sql
            String sql ="insert into t_user values("+request.getParameter("username")+",'','','2000-01-01','MALE','','"+request.getParameter("password")+"')";
            //执行sql
            if (template != null) {
                int update = template.executeUpdate(sql);
            }
            request.setAttribute("state","注册成功");
            request.getSession().setAttribute("username",request.getParameter("username"));
            request.getSession().setAttribute("password",request.getParameter("password"));
            request.getRequestDispatcher("login.jsp").forward(request,response);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    try {
        if(request.getParameter("login")!=null){
            //定义sql
            String sql ="select * from t_user where nickname='"+request.getParameter("username")+"' and passwd='"+request.getParameter("password")+"'";
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
        output.print(e.toString()+"login failed"+request.getParameter("username")+request.getParameter("password"));
    }
%>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>登录|注册</title>
    <!-- 图标库npmjs.com -->

    <link rel="stylesheet" href="https://unpkg.com/font-awesome@4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="css/login.css">
    <link rel="stylesheet" type="text/css" href="css/float_windows.css">

</head>
<body>
<div class="outer-menu">
    <input class="checkbox-toggle" type="checkbox" />
    <div class="hamburger">
        <div></div>
    </div>
    <div class="menu">
        <div>
            <div>
                <ul>
                    <li><a href="./index.html">首页</a></li>
                    <li><a href="./upload.html">上传</a></li>
                    <li><a href="./star.html">收藏</a></li>
                    <li><a href="./set.html">设置</a></li>
                    <li><a href="login.jsp">登录/注册</a></li>
                    <li><a href="#" onclick="log_out()">登出</a></li>
                </ul>
            </div>
        </div>
    </div>
</div>

<!-- 使用到字体图标，从fontAwesome里icon中找 -->
<header>
    <a class="login" href="#"><i class="fa fa-user-circle"></i></a>
</header>

<main>
    <div class="flip-modal login">
        <!-- 展示登录页面 -->

        <div class="modal modal-login">
            <a class="close" href="#"><i class="fa fa-close"></i></a>
            <!-- 登录 -->
            ${state}
            <div class="tabs">
                <a class="login active" href="#">登录</a>
                <a class="register" href="#">注册</a>
            </div>
            <div class="content">
                <div class="errormsg"></div>
                <form action="login.jsp" method="post">
                    <div class="input-field">
                        <i class="fa fa-user-o"></i>
                        <input name="username" type="text" placeholder="用户名">
                    </div>
                    <div class="input-field">
                        <i class="fa fa-lock"></i>
                        <input name="password" type="password" placeholder="密码">
                    </div>
                    <div class="input-field">
                        <input type="submit" name="login" value="登录">
                    </div>
                </form>
            </div>
        </div>

        <!-- 展示注册页面 -->
        <div class="modal modal-register">
            ${i}
            <a class="close fa fa-close" href="#"></a>
            <div class="tabs">
                <a class="login" href="#">登录</a>
                <a class="register active" href="#">注册</a>
            </div>
            <div class="content">
                <div class="errormsg"></div>
                <form action="login.jsp" method="post">
                    <div class="input-field">
                        <i class="fa fa-user-o"></i>
                        <input name="username" type="text" placeholder="输入用户名">
                    </div>
                    <div class="input-field">
                        <i class="fa fa-lock"></i>
                        <input name="password" type="password" placeholder="输入密码">
                    </div>
                    <div class="input-field">
                        <i class="fa fa-lock"></i>
                        <input name="password2"  type="password" placeholder="再次输入密码">
                    </div>
                    <div class="input-field">
                        <input type="submit" name="reg" value="注册">
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
<script>
    if("<%=session.getAttribute("username") %>"!=null){
        localStorage.setItem("token","<%=session.getAttribute("username")%>");
    }
    function log_out(){
        if(localStorage.getItem("token") == null){
            alert("还未登录");
            return;
        }
        <%--axios.post("http://43.139.215.45:80/api/User", {--%>
        <%--    action: "logout",--%>
        <%--}, {headers: {Authorization: ` ${localStorage.getItem("token")}`},--%>
        <%--})--%>
        <%--    .then(function (response) {--%>
        <%--        console.log(response)--%>
        <%--        if(response.data.ret == 1){--%>
        <%--            alert(response.data.msg);--%>
        <%--            window.localStorage.removeItem("token");--%>
        <%--        }else{--%>
        <%--            alert("登出成功")--%>
        <%--            window.localStorage.removeItem("token");--%>
        <%--            window.location.href = "./index.html";--%>
        <%--        }--%>
        <%--    })--%>
    }

    function $(selector){
        return document.querySelector(selector)
    }
    function $$(selector){
        return document.querySelectorAll(selector)
    }
    $$('.modal .login').forEach(function(node){
        node.onclick = function(){
            $('.flip-modal').classList.remove('register')
            $('.flip-modal').classList.add('login')
        }
    })
    $$('.modal .register').forEach(function(node){
        node.onclick = function(){
            $('.flip-modal').classList.remove('login')
            $('.flip-modal').classList.add('register')
        }
    })
    $(".close").onclick = function(){
        $('.flip-modal').classList.remove('show')
    }
    $(".flip-modal").onclick=function(e){
        e.stopPropagation()
    }

    $('header .login').onclick = function(e){
        e.stopPropagation()
        $('.flip-modal').classList.add('show')
    }

    // $('.modal-login form').addEventListener('submit', function(e){
    //     e.preventDefault()
    //     var username = $('.modal-login input[name=username]').value;
    //     var password = $('.modal-login input[name=password]').value;
    //     if(localStorage.getItem("token") != null){
    //         alert("已经登录了");
    //         return;
    //     }
    //     if(!/^\w{3,8}$/.test(username)){
    //         $('.modal-login .errormsg').innerText = '用户名需输入3-8个字符，包括字母数字下划线'
    //         return false
    //     }
    //     if(!/^\w{6,10}$/.test(password)){
    //         $('.modal-login .errormsg').innerText = '密码需输入6-10个字符，包括字母数字下划线'
    //         return false
    //     }
    // })

    // $('.modal-register form').addEventListener('submit', function(e){
    //     e.preventDefault()
    //     if(!/^\w{3,8}$/.test($('.modal-register input[name=username]').value)){
    //         $('.modal-register .errormsg').innerText = '用户名需输入3-8个字符，包括字母数字下划线'
    //         return false
    //     }
    //     if(/^hunger$|^ruoyu$/.test($('.modal-register input[name=username]').value)){
    //         $('.modal-register .errormsg').innerText = '用户名已存在'
    //         return false
    //     }
    //     if(!/^\w{6,10}$/.test($('.modal-register input[name=password]').value)){
    //         $('.modal-register .errormsg').innerText = '密码需输入6-10个字符，包括字母数字下划线'
    //         return false
    //     }
    //     if($('.modal-register input[name=password]').value !== $('.modal-register input[name=password2]').value){
    //         $('.modal-register .errormsg').innerText = '两次输入的密码不一致'
    //         return false
    //     }
    // })

</script>
</body>
</html>



<%@ page language="java"
         import="java.io.*, java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*" %>
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

    public String getUsername(HttpServletRequest request) {
        if (request.getHeader("Authorization").isEmpty()) {
            return "";
        }
        return request.getHeader("Authorization");
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

    String postData = getPostData(request.getInputStream(), request.getContentLength());
    JSONObject jsonData = JSONObject.fromObject(postData);
    String action = jsonData.getString("action");
    PrintWriter output = response.getWriter();
    try {
        if ("login".equals(action)) {
            // need to check if the login has logined!!!
            String username = jsonData.getString("username");
            String password = jsonData.getString("password");
            //定义sql
            String sql = "select * from t_user where nickname='" + username + "' and passwd='" + password + "'";
            //执行sql
            ResultSet rs = null;
            if (conn != null) {
                rs = conn.executeQuery(sql);
            }
            String res;
            if (rs != null && rs.next()) {
                res = "{\"ret\": 0, \"msg\":\"登录成功\", \"token\": \"" + username + "\"}";
            } else {
                res = "{\"ret\": 1, \"msg\":\"登录失败\"}";
            }
            sendJsonData(res, response);
            response.getWriter().close();
        } else if ("register".equals(action)) {
            jsonData = JSONObject.fromObject(jsonData.getString("data"));
            String username = jsonData.getString("username");
            String password = jsonData.getString("passwd");
            String sql = "select * from t_user where nickname='" + username + "'";
            ResultSet rs = null;
            if (conn != null) {
                rs = conn.executeQuery(sql);
            }
            String res;
            // warning: need to check whether insert success!!!!
            if (rs != null && rs.next()) {
                res = "{\"ret\": 1, \"msg\":\"用户已存在\"}";
            } else {
                String query = "insert into t_user(nickname,passwd) values('" + username + "','" + password + "')";
                if (conn != null) {
                    conn.executeUpdate(query);
                }
                res = "{\"ret\": 0, \"msg\":\"注册成功\"}";
            }
            sendJsonData(res, response);
            response.getWriter().close();
        } else if ("logout".equals(action)) {
            // need to check if the login has logined!!!
            String res;
            if (!getUsername(request).isEmpty()) {
                res = "{\"ret\": 0, \"msg\":\"退出成功\"}";
            } else {
                res = "{\"ret\": 1, \"msg\":\"未登录\"}";
            }
            sendJsonData(res, response);
            response.getWriter().close();
        } else if ("update".equals(action)) {
            String res = "";
            if (getUsername(request).isEmpty()) {
                res = "{\"ret\": 1, \"msg\":\"未登录\"}";
            } else {
                boolean usernameExist = false;
                String username = getUsername(request);
                JSONObject info = jsonData.getJSONObject("newinfo");
                String nickname = jsonData.getString("nickname");
                String email = info.getString("email");
                String sex = info.getString("sex");
                String wechat = info.getString("wechat");
                String country = info.getString("country");
                String birthday = info.getString("birthday");
                // check if the new username valid
                if (!nickname.isEmpty()) {
                    String query = "select * from t_user where nickname='" + nickname + "'";
                    ResultSet rs = null;
                    if (conn != null) {
                        rs = conn.executeQuery(query);
                    }
                    if (rs != null && rs.next()) {
                        res = "{\"ret\": 1, \"msg\":\"用户名已存在\"}";
                        usernameExist = true;
                    }
                }
                if (!usernameExist) {
                    if (!email.isEmpty()) {
                        String query = "update t_user set email='" + email + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (!sex.isEmpty()) {
                        String query = "update t_user set gender='" + sex + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (!wechat.isEmpty()) {
                        String query = "update t_user set wechat='" + wechat + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (!country.isEmpty()) {
                        String query = "update t_user set country='" + country + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (!birthday.isEmpty()) {
                        String query = "update t_user set birthday='" + birthday + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (!nickname.isEmpty()) {
                        String query = "update t_user set nickname='" + nickname + "' where nickname='" + username + "'";
                        if (conn != null) {
                            conn.executeUpdate(query);
                        }
                    }
                    if (nickname.isEmpty()) {
                        nickname = username;
                    }
                    res = "{\"ret\": 0, \"msg\": \"更新成功\", \"token\": \"" + nickname + "\"}";
                }
            }
            sendJsonData(res, response);
            response.getWriter().close();

        } else if ("getinfo".equals(action)) {
            String res = "";
            if (getUsername(request).isEmpty()) {
                res = "{\"ret\": 1, \"msg\":\"未登录\"}";
            } else {
                String username = getUsername(request);
                String query = "select * from t_user where nickname='" + username + "'";
                ResultSet rs = null;
                if (conn != null) {
                    rs = conn.executeQuery(query);
                }
                if (rs != null && rs.next()) {
                    String userinfo = "{\"username\":\"" + rs.getString("nickname") + "\""
                            + ", \"email\":\"" + rs.getString("email") + "\""
                            + ", \"birthday\":" + rs.getString("birthday")
                            + ", \"sex\":" + rs.getString("gender")
                            + ", \"country\":\"" + rs.getString("country") + "\""
                            + ", \"wechat\":\"" + rs.getString("wechat") + "\"}";
                    res = "{\"ret\":0, \"userinfo\":" + userinfo + "}";
                }
            }
            sendJsonData(res, response);
            response.getWriter().close();
        } else {
            String res = "{\"ret\":1, \"msg\":\"未找到处理该请求的方法\"}";
            sendJsonData(res, response);
            response.getWriter().close();
        }
    } catch (Exception e) {
        e.printStackTrace();
        output.print(e.toString() + "login failed" + request.getParameter("username") + request.getParameter("password"));
    }
%>


<%@ page language="java" import="java.io.*,javax.sql.*, javax.naming.*,java.util.*,java.sql.*, org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.disk.DiskFileItem, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*"%>
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
        byte buf[] = new byte[size];
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
    if(request.getHeader("Authorization")==null){
        sendJsonData("no user massage",response);
        response.getWriter().close();
    }
    else {
        String token = request.getHeader("Authorization");
        String action = request.getParameter("action");
        try{
            String sql = "";
            if(action.equals("upload_list")){
                sql = "select * from t_image where uploader = '" + token + "'";
            }
            else if(action.equals("favor_list")){
                sql =  "select * from t_favor where uploader = '" + token + "'";
            }
            else if(action.equals("pic_info")){
                String pid = request.getParameter("pid");
                sql = "select * from t_image where pid = '" + pid + "'";
            }
            ResultSet rs = conn.executeQuery(sql);
            String res = "{\"ret\":0, \"picList\":[";
            String sep = "";
            while (rs.next()) {
                String pid = rs.getString("pid");
                String name = rs.getString("name");
                String url = rs.getString("URL");
                String uploader = rs.getString("uploader");
                if(action.equals("check_upload")&&uploader.equals(token)){
                    
                }
                String upload_time = rs.getString("upload_time");
                int num_like = rs.getInt("num_like");
                int num_star = rs.getInt("num_star");
                int num_view = rs.getInt("num_view");
                String width = "960"; //= rs.getString("");
                String height = "640"; // = rs.getString("");
                String o = "{\"url\":\"" + url + "\",\"width\":" + width + ",\"height\":" + height + ",\"uploader\":"+ uploader + ",\"upload_time\":"+ upload_time + ",\"num_like\":"+ num_like + ",\"num_star\":"+ num_star + ",\"num_view\":"+ num_view +",\"name\":"+ name +"}";
                res += sep + o;
                sep = ",";
            }
            res += "]}";
            sendJsonData(res, response);
            response.getWriter().close();
        }catch (Exception e){
            e.printStackTrace();
            out.print(e.toString());
        }

    }
%>
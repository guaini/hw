package com.dao;
import com.domain.User;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.*;
import java.util.List;

public class DaoImpl implements Dao{
    private static final String DRIVER = "com.mysql.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/school";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";
    private static final Statement template = getConn();
    public static Statement getConn(){
        Statement conn = null;
        String connectString = "jdbc:mysql://172.18.187.253:3306/db_image_sharing"
                + "?autoReconnect=true&useUnicode=true"
                + "&characterEncoding=UTF-8";
        StringBuilder table=new StringBuilder("");
        try{
            Class.forName("com.mysql.jdbc.Driver");
            Connection con=DriverManager.getConnection(connectString,
                    "user", "123");
            Statement stmt=con.createStatement();
            conn = stmt;
            stmt.close();
            con.close();
        }
        catch (Exception e){
        }
        return conn;
    }
    @Override
    public User login(User user) {
        try {
            //定义sql
            String sql = "select * from user where UID = "+user.getUsername()+" and password ="+user.getPassword();
            //执行sql
            ResultSet rs = template.executeQuery(sql);
            User user1 = new User();
            //返回结果
            if(rs.getRow()!=0) {
                user1.setId(Integer.parseInt(rs.getString("UID")));
                user1.setPassword(rs.getString("password"));
            }
            return user1;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public int addUser(User user) {
        try {
            //定义sql
            String sql ="insert into user values(null,"+user.getUsername()+","+user.getPassword()+")";
            //执行sql
            int update = template.executeUpdate(sql);
            return update;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
}

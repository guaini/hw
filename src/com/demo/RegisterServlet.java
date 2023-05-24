package com.demo;

import com.dao.Dao;
import com.dao.DaoImpl;
import com.domain.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //设置编码格式
        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf-8");
        //获取数据
        //封装数据
        User user = new User();
        user.setId(Integer.parseInt(request.getParameter("username")));
        user.setPassword(request.getParameter("password"));
        request.setAttribute("user",request.getParameter("username"));
        request.setAttribute("psd",request.getParameter("password"));
        //调用dao
        Dao dao = new DaoImpl();
        String i = dao.addUser(user);
        request.setAttribute("i",i);
        if (!i.equals("0")){
            request.setAttribute("user2","注册成功请登录");
            request.getRequestDispatcher("login.jsp").forward(request,response);
        }else {
            request.setAttribute("user2","注册失败，请重试");
            request.getRequestDispatcher("login.jsp").forward(request,response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);
    }
}

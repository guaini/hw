package com.dao;

import com.domain.*;
import com.domain.User;

import java.util.List;

public interface Dao {
    //用户登录
    public User login(User user);
    //用户注册
    public int addUser(User user);
}

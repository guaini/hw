package com.domain;

public class Favorite {
    private int PID;
    private int user;
    public int getPID(){
        return PID;
    }
    public int getUser(){
        return user;
    }
    public void setPID(int id){
        this.PID = id;
    }
    public void setUser(int uid){
        this.user = uid;
    }
}

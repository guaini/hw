package com.domain;

import java.util.Date;

public class Image {
    private int PID;
    private String URL;
    private String resolution;
    private Date upload_time;
    private int num_like;
    private int num_star;
    private int num_view;
    private int uploader;

    public int getPID(){
        return PID;
    }
    public String getURL(){
        return URL;
    }
    public String getResolution(){
        return resolution;
    }
    public Date getUpload_time(){
        return upload_time;
    }
    public int getNum_like(){
        return num_like;
    }
    public int getNum_star(){
        return num_star;
    }
    public int getNum_view(){
        return num_view;
    }
    public int getUploader(){
        return uploader;
    }
    public void setPID(int id){
        this.PID = id;
    }
    public void setURL(String url){
        this.URL = url;
    }
    public void setResolution(String resolution){
        this.resolution = resolution;
    }
    public void setUpload_time(Date upload_time){
        this.upload_time = upload_time;
    }
    public void setNum_like(int num_like){
        this.num_like = num_like;
    }
    public void setNum_star(int num_star){
        this.num_star = num_star;
    }
    public void setNum_view(int num_view){
        this.num_view = num_view;
    }
    public void setUploader(int id){
        this.uploader = id;
    }
}

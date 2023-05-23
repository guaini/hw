package com.domain;

public class User {
    private int UID;
    private String nickname;
    private String birthday;
    private String gender;
    private String country;
    private String password;

    public int getId() {
        return UID;
    }

    public void setId(int id) {
        this.UID = id;
    }

    public String getUsername() {
        return nickname;
    }

    public void setUsername(String username) {
        this.nickname = username;
    }
    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }
    public String getBirthday() {
        return birthday;
    }

    public void setBirthday(String birthday) {
        this.birthday = birthday;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}

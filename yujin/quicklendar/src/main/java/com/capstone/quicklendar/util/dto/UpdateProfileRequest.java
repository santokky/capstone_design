package com.capstone.quicklendar.util.dto;

public class UpdateProfileRequest {

    private String name;
    private String phone;
    private String password;

    // 기본 생성자
    public UpdateProfileRequest() {
    }

    // 모든 필드를 받는 생성자
    public UpdateProfileRequest(String name, String phone, String password) {
        this.name = name;
        this.phone = phone;
        this.password = password;
    }

    // Getter 및 Setter
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}

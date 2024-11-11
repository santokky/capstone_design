package com.capstone.quicklendar.util.dto;

public class JwtResponse {
    private String token;
    private String tokenType;
    private String name;
    private String email;

    public JwtResponse(String token) {
        this.token = token;
    }

    public JwtResponse(String token, String tokenType, String name, String email) {
        this.token = token;
        this.tokenType = tokenType;
        this.name = name;
        this.email = email;
    }

    public String getToken() {
        return token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }
}

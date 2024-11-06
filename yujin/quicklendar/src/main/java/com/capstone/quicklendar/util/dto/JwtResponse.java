package com.capstone.quicklendar.util.dto;

public class JwtResponse {
    private String token;
    private String tokenType;

    public JwtResponse(String token, String tokenType) {
        this.token = token;
        this.tokenType = tokenType;
    }

    public String getToken() {
        return token;
    }

    public String getTokenType() {
        return tokenType;
    }
}

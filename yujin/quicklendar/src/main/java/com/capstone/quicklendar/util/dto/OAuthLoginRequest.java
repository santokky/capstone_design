package com.capstone.quicklendar.util.dto;

public class OAuthLoginRequest {
    private String provider;  // "google" or "naver"
    private String authorizationCode;

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getAuthorizationCode() {
        return authorizationCode;
    }

    public void setAuthorizationCode(String authorizationCode) {
        this.authorizationCode = authorizationCode;
    }
}

package com.capstone.quicklendar.util.dto;

public class OAuthUnlinkRequest {
    private String provider;
    private String providerId;

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }
}

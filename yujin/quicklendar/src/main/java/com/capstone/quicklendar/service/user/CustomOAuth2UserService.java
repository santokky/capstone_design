package com.capstone.quicklendar.service.user;

import com.capstone.quicklendar.domain.user.CustomOAuth2User;
import com.capstone.quicklendar.domain.user.OAuthToken;
import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.domain.user.UserType;
import com.capstone.quicklendar.repository.user.OAuthUserRepository;
import com.capstone.quicklendar.repository.user.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Map;

@Service
public class CustomOAuth2UserService implements OAuth2UserService<OAuth2UserRequest, OAuth2User> {

    private final UserRepository userRepository;
    private final OAuthUserRepository oauthUserRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    public CustomOAuth2UserService(UserRepository userRepository, OAuthUserRepository oauthUserRepository) {
        this.userRepository = userRepository;
        this.oauthUserRepository = oauthUserRepository;
    }

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleClientId;

    @Value("${spring.security.oauth2.client.registration.google.client-secret}")
    private String googleClientSecret;

    @Value("${spring.security.oauth2.client.registration.google.redirect-uri}")
    private String googleRedirectUri;

    @Value("${spring.security.oauth2.client.registration.naver.client-id}")
    private String naverClientId;

    @Value("${spring.security.oauth2.client.registration.naver.client-secret}")
    private String naverClientSecret;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();
        OAuth2User oAuth2User = delegate.loadUser(userRequest);

        final String provider = userRequest.getClientRegistration().getRegistrationId();
        final Map<String, Object> attributes = oAuth2User.getAttributes();
        final String providerId;
        final String email;
        final String name;
        final String phone;

        if ("naver".equals(provider)) {
            Map<String, Object> response = (Map<String, Object>) attributes.get("response");
            providerId = (response != null) ? (String) response.get("id") : null;
            email = (response != null) ? (String) response.get("email") : null;
            name = (response != null) ? (String) response.get("name") : null;
            phone = (response != null) ? (String) response.get("mobile") : null;
        } else if ("google".equals(provider)) {
            providerId = (String) attributes.get("sub");
            email = (String) attributes.get("email");
            name = (String) attributes.get("name");
            phone = null;
        } else {
            throw new OAuth2AuthenticationException("지원하지 않는 OAuth 제공자입니다.");
        }

        User user = userRepository.findByEmail(email)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    newUser.setName(name);
                    newUser.setPhone(phone);
                    newUser.setUserType(UserType.OAUTH);
                    newUser.setProvider(provider);
                    newUser.setProvider_id(providerId);
                    newUser.setEnabled(true);
                    return userRepository.save(newUser);
                });

        String accessToken = userRequest.getAccessToken().getTokenValue();
        Instant expiresAt = userRequest.getAccessToken().getExpiresAt();

        OAuthToken oauthToken = oauthUserRepository.findByProviderAndProviderId(provider, providerId)
                .orElseGet(() -> {
                    OAuthToken newOAuthToken = new OAuthToken();
                    newOAuthToken.setUser(user);
                    newOAuthToken.setProvider(provider);
                    newOAuthToken.setProviderId(providerId);
                    newOAuthToken.setAccessToken(accessToken);
                    newOAuthToken.setExpiresAt(expiresAt != null ? Timestamp.from(expiresAt) : null);
                    newOAuthToken.setCreatedAt(LocalDateTime.now());
                    return oauthUserRepository.save(newOAuthToken);
                });

        return new CustomOAuth2User(user, attributes);
    }

    public String getAccessToken(String providerType, String authorizationCode, String state) {
        String tokenUrl;
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();

        if ("google".equalsIgnoreCase(providerType)) {
            tokenUrl = "https://oauth2.googleapis.com/token";
            params.add("grant_type", "authorization_code");
            params.add("client_id", googleClientId);
            params.add("client_secret", googleClientSecret);
            params.add("code", authorizationCode);
            params.add("redirect_uri", googleRedirectUri);
        } else if ("naver".equalsIgnoreCase(providerType)) {
            tokenUrl = "https://nid.naver.com/oauth2.0/token";
            params.add("grant_type", "authorization_code");
            params.add("client_id", naverClientId);
            params.add("client_secret", naverClientSecret);
            params.add("code", authorizationCode);
            params.add("state", state);
        } else {
            throw new IllegalArgumentException("Unsupported provider: " + providerType);
        }

        HttpHeaders headers = new HttpHeaders();
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(tokenUrl, request, Map.class);
        Map<String, Object> body = response.getBody();

        return (String) body.get("access_token");
    }

    public Map<String, Object> getNaverUserProfile(String accessToken) {
        String profileUrl = "https://openapi.naver.com/v1/nid/me";
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        ResponseEntity<Map> response = restTemplate.exchange(profileUrl, HttpMethod.GET, entity, Map.class);
        return response.getBody();
    }

    public Map<String, Object> getGoogleUserProfile(String accessToken) {
        String profileUrl = "https://www.googleapis.com/oauth2/v1/userinfo";
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        ResponseEntity<Map> response = restTemplate.exchange(profileUrl, HttpMethod.GET, entity, Map.class);

        return response.getBody();
    }
}
package com.capstone.quicklendar.service.user;

import com.capstone.quicklendar.domain.user.CustomOAuth2User;
import com.capstone.quicklendar.domain.user.OAuthToken;
import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.domain.user.UserType;
import com.capstone.quicklendar.repository.user.OAuthUserRepository;
import com.capstone.quicklendar.repository.user.UserRepository;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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

    public CustomOAuth2UserService(UserRepository userRepository, OAuthUserRepository oauthUserRepository) {
        this.userRepository = userRepository;
        this.oauthUserRepository = oauthUserRepository;
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2UserService<OAuth2UserRequest, OAuth2User> delegate = new DefaultOAuth2UserService();
        OAuth2User oAuth2User = delegate.loadUser(userRequest);

        // 제공자 정보 가져오기 (예: "naver", "google")
        final String provider = userRequest.getClientRegistration().getRegistrationId();
        final Map<String, Object> attributes = oAuth2User.getAttributes();
        final String providerId;
        final String email;
        final String name;
        final String phone;

        // 네이버와 구글에 따른 사용자 정보 추출
        if ("naver".equals(provider)) {
            // 네이버 OAuth 사용자 정보 가져오기
            Map<String, Object> response = (Map<String, Object>) attributes.get("response");
            providerId = (response != null) ? (String) response.get("id") : null;
            email = (response != null) ? (String) response.get("email") : null;
            name = (response != null) ? (String) response.get("name") : null;
            phone = (response != null) ? (String) response.get("mobile") : null;
        } else if ("google".equals(provider)) {
            // 구글 OAuth 사용자 정보 가져오기
            providerId = (String) attributes.get("sub");
            email = (String) attributes.get("email");
            name = (String) attributes.get("name");
            // 구글은 전화번호를 제공하지 않음
            phone = null;
        } else {
            throw new OAuth2AuthenticationException("지원하지 않는 OAuth 제공자입니다.");
        }

        // 사용자 저장 또는 검색 로직
        User user = userRepository.findByEmail(email)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    newUser.setName(name);
                    newUser.setPhone(phone);
                    newUser.setUserType(UserType.OAUTH);
                    newUser.setProvider(provider); // OAuth 제공자 정보 저장
                    newUser.setProvider_id(providerId); // OAuth 제공자의 사용자 ID 저장
                    newUser.setEnabled(true);
                    return userRepository.save(newUser);
                });

        // Access Token과 만료 시간 가져오기
        String accessToken = userRequest.getAccessToken().getTokenValue();
        Instant expiresAt = userRequest.getAccessToken().getExpiresAt();

        // OAuthToken 저장 또는 업데이트
        OAuthToken oauthToken = oauthUserRepository.findByProviderAndProviderId(provider, providerId)
                .orElseGet(() -> {
                    OAuthToken newOAuthToken = new OAuthToken();
                    newOAuthToken.setUser(user);
                    newOAuthToken.setProvider(provider);
                    newOAuthToken.setProviderId(providerId);
                    newOAuthToken.setAccessToken(accessToken);
                    newOAuthToken.setExpiresAt(expiresAt != null ? Timestamp.from(expiresAt) : null); // 만료시간 설정
                    newOAuthToken.setCreatedAt(LocalDateTime.now());
                    return oauthUserRepository.save(newOAuthToken);
                });

        // OAuth 사용자 정보 반환
        return new CustomOAuth2User(user, attributes);
    }

    public void unlinkOAuthUser(String providerId, String provider) {
        // OAuth 사용자 정보 조회
        OAuthToken oauthToken = oauthUserRepository.findByProviderAndProviderId(provider, providerId)
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 providerId 또는 provider입니다."));

        String accessToken = oauthToken.getAccessToken();
        String refreshToken = oauthToken.getRefreshToken();

        boolean revokeSuccess = false;  // 연동 해제 성공 여부

        // 소셜 제공자에 따라 토큰 해제 로직 분기
        if ("naver".equals(provider)) {
            revokeNaverToken(accessToken); // 네이버 연동 해제
            revokeSuccess = true;
        } else if ("google".equals(provider)) {
            revokeGoogleToken(accessToken, refreshToken); // 구글 연동 해제
            revokeSuccess = true;
        }

        if (revokeSuccess) {
            // OAuth 사용자 정보를 데이터베이스에서 삭제
            oauthUserRepository.delete(oauthToken);
            userRepository.delete(oauthToken.getUser());

            // 사용자 로그아웃 처리
            SecurityContextHolder.clearContext();
        } else {throw new RuntimeException("연동 해제 실패");
        }
    }


    // 구글 연동 해제 메서드
    private void revokeGoogleToken(String accessToken, String refreshToken) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "https://oauth2.googleapis.com/revoke?token=" + accessToken;

        try {
            // 액세스 토큰 해제 요청
            ResponseEntity<String> response = restTemplate.postForEntity(url, null, String.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                System.out.println("Google Access Token 연동 해제 성공");

                // Refresh Token도 해제
                if (refreshToken != null) {
                    String refreshUrl = "https://oauth2.googleapis.com/revoke?token=" + refreshToken;
                    ResponseEntity<String> refreshResponse = restTemplate.postForEntity(refreshUrl, null, String.class);
                    if (refreshResponse.getStatusCode() == HttpStatus.OK) {
                        System.out.println("Google Refresh Token 연동 해제 성공");
                    } else {
                        throw new RuntimeException("Google Refresh Token 연동 해제 실패");
                    }
                }
            } else {
                throw new RuntimeException("Google Access Token 연동 해제 실패");
            }
        } catch (Exception e) {
            throw new RuntimeException("Google 연동 해제 중 오류 발생: " + e.getMessage());
        }
    }

    // 네이버 연동 해제 메서드
    private void revokeNaverToken(String accessToken) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "https://nid.naver.com/oauth2.0/token";

        // 요청 파라미터 설정
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "delete");
        params.add("client_id", "");  // 네이버 클라이언트 ID 설정
        params.add("client_secret", "");  // 네이버 클라이언트 시크릿 설정
        params.add("access_token", accessToken);
        params.add("service_provider", "naver");

        // 요청 전송
        HttpHeaders headers = new HttpHeaders();
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                System.out.println("네이버 연동 해제 성공");
            } else {
                throw new RuntimeException("네이버 연동 해제 실패");
            }
        } catch (Exception e) {
            throw new RuntimeException("OAuth 사용자 연동 해제 중 오류 발생: " + e.getMessage());
        }
    }

}
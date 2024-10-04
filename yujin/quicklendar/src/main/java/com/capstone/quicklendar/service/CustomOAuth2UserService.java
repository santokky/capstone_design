package com.capstone.quicklendar.service;

import com.capstone.quicklendar.domain.CustomOAuth2User;
import com.capstone.quicklendar.domain.OAuthUser;
import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;
import com.capstone.quicklendar.repository.OAuthUserRepository;
import com.capstone.quicklendar.repository.UserRepository;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;

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

        // 네이버는 response 내부에 사용자 정보가 있음
        Map<String, Object> attributes = oAuth2User.getAttributes();
        Map<String, Object> response = (Map<String, Object>) attributes.get("response");

        String email = (String) response.get("email");
        String name = (String) response.get("name");
        String phone = (String) response.get("mobile");

        // 사용자 저장 또는 검색 로직
        User user = userRepository.findByEmail(email)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setEmail(email);
                    newUser.setName(name);
                    newUser.setPhone(phone);
                    newUser.setUserType(UserType.OAUTH);
                    newUser.setEnabled(true);
                    return userRepository.save(newUser);
                });

        return new CustomOAuth2User(user, attributes); // CustomOAuth2User 객체 반환
    }

    // 연동 해제 메서드
    public void unlinkOAuthUser(Long userId) {
        // 해당 사용자 조회
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            // OAuthUser가 존재하면 먼저 삭제
            oauthUserRepository.deleteById(user.get().getOauthUser().getId());
            // 그 후 사용자 삭제
            userRepository.deleteById(userId);
        } else {
            throw new IllegalArgumentException("해당 사용자가 존재하지 않습니다.");
        }
    }
}
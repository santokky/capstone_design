package com.capstone.quicklendar.config;

import com.capstone.quicklendar.repository.user.OAuthUserRepository;
import com.capstone.quicklendar.repository.user.UserRepository;
import com.capstone.quicklendar.service.user.CustomOAuth2UserService;
import com.capstone.quicklendar.util.jwt.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizationRequestResolver;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestResolver;

@Configuration
@EnableWebSecurity
public class OAuthConfig {

    private final UserRepository userRepository;
    private final OAuthUserRepository oauthUserRepository;
    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public OAuthConfig(UserRepository userRepository, OAuthUserRepository oauthUserRepository, JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.oauthUserRepository = oauthUserRepository;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Bean
    public OAuth2AuthorizationRequestResolver authorizationRequestResolver(ClientRegistrationRepository clientRegistrationRepository) {
        return new DefaultOAuth2AuthorizationRequestResolver(clientRegistrationRepository, "/oauth2/authorization");
    }

    @Bean
    public CustomOAuth2UserService customOAuth2UserService() {
        return new CustomOAuth2UserService(userRepository, oauthUserRepository);
    }
}
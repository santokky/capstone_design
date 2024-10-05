package com.capstone.quicklendar.config;

import com.capstone.quicklendar.repository.OAuthUserRepository;
import com.capstone.quicklendar.repository.UserRepository;
import com.capstone.quicklendar.service.CustomOAuth2UserService;
import com.capstone.quicklendar.service.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.RequestEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.endpoint.DefaultAuthorizationCodeTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AccessTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequest;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequestEntityConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.util.MultiValueMap;

@Configuration
public class SecurityConfig {

    private final CustomUserDetailsService customUserDetailsService;
    private final UserRepository userRepository;
    private final OAuthUserRepository oauthUserRepository;

    public SecurityConfig(CustomUserDetailsService customUserDetailsService, UserRepository userRepository, OAuthUserRepository oauthUserRepository) {
        this.customUserDetailsService = customUserDetailsService;
        this.userRepository = userRepository;
        this.oauthUserRepository = oauthUserRepository;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(authz -> authz
                        .requestMatchers("/", "/index", "/login", "/join", "/resources/**", "/oauth2/**").permitAll()
                        .anyRequest().authenticated()
                )
                .oauth2Login(oauth -> oauth
                        .loginPage("/login")
                        .tokenEndpoint(token -> token
                                .accessTokenResponseClient(accessTokenResponseClient()) // 커스텀 클라이언트 사용
                        )
                        .userInfoEndpoint(userInfo -> userInfo
                                .userService(customOAuth2UserService())  // CustomOAuth2UserService 사용
                        )
                        .defaultSuccessUrl("/", true)
                        .failureUrl("/login?error=true")
                )
                .formLogin(login -> login
                        .loginPage("/login")
                        .defaultSuccessUrl("/", true)
                        .permitAll()
                )
                .logout(logout -> logout.permitAll())
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                        .maximumSessions(1)
                );

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(customUserDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder()); // BCryptPasswordEncoder 사용
        return authProvider;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return customUserDetailsService;
    }

    @Bean
    public CustomOAuth2UserService customOAuth2UserService() {
        return new CustomOAuth2UserService(userRepository, oauthUserRepository);
    }

    @Bean
    public OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> accessTokenResponseClient() {
        DefaultAuthorizationCodeTokenResponseClient tokenResponseClient = new DefaultAuthorizationCodeTokenResponseClient();

        tokenResponseClient.setRequestEntityConverter(new OAuth2AuthorizationCodeGrantRequestEntityConverter() {
            @Override
            public RequestEntity<?> convert(OAuth2AuthorizationCodeGrantRequest authorizationGrantRequest) {
                RequestEntity<?> originalRequest = super.convert(authorizationGrantRequest);
                MultiValueMap<String, String> body = (MultiValueMap<String, String>) originalRequest.getBody();

                // 네이버와 구글 각각에 대해 client_secret을 추가
                String provider = authorizationGrantRequest.getClientRegistration().getRegistrationId();
                if ("naver".equals(provider)) {
                    body.add("client_secret", "{}");  // 네이버 시크릿
                } else if ("google".equals(provider)) {
                    body.add("client_secret", "");  // 구글 시크릿
                }

                return new RequestEntity<>(body, originalRequest.getHeaders(), originalRequest.getMethod(), originalRequest.getUrl());
            }
        });

        return tokenResponseClient;
    }

}


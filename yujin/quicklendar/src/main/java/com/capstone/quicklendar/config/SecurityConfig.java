package com.capstone.quicklendar.config;

import com.capstone.quicklendar.repository.user.OAuthUserRepository;
import com.capstone.quicklendar.repository.user.UserRepository;
import com.capstone.quicklendar.service.user.CustomOAuth2UserService;
import com.capstone.quicklendar.service.user.CustomUserDetailsService;
import com.capstone.quicklendar.util.jwt.JwtAuthenticationFilter;
import com.capstone.quicklendar.util.jwt.JwtTokenProvider;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
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
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.util.MultiValueMap;

@Configuration
public class SecurityConfig {

    private final CustomUserDetailsService customUserDetailsService;
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> authorizationCodeTokenResponseClient;
    private final OAuthConfig oAuthConfig;

    @Autowired
    public SecurityConfig(CustomUserDetailsService customUserDetailsService, JwtTokenProvider jwtTokenProvider,
                          CustomOAuth2UserService customOAuth2UserService,
                          OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> authorizationCodeTokenResponseClient,
                          OAuthConfig oAuthConfig) {
        this.customUserDetailsService = customUserDetailsService;
        this.jwtTokenProvider = jwtTokenProvider;
        this.customOAuth2UserService = customOAuth2UserService;
        this.authorizationCodeTokenResponseClient = authorizationCodeTokenResponseClient;
        this.oAuthConfig = oAuthConfig;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider, customUserDetailsService), UsernamePasswordAuthenticationFilter.class)
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authz -> authz
                        .requestMatchers("/", "/index", "/login", "/join", "/resources/**", "/oauth2/**", "/api/users/**",
                                "/competitions/main", "/competitions/filter", "/competitions/details/**", "/images/**").permitAll()
                        .anyRequest().authenticated())
                .exceptionHandling(exceptions -> exceptions
                        .authenticationEntryPoint((request, response, authException) -> {
                            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
                        })
                        .accessDeniedHandler((request, response, accessDeniedException) -> {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
                        }))
                .oauth2Login(oauth2 -> oauth2
                        .authorizationEndpoint(authorization -> authorization
                                .baseUri("/oauth2/authorize"))  // OAuth2 인증 엔드포인트 설정
                        .tokenEndpoint(token -> token
                                .accessTokenResponseClient(oAuthConfig.accessTokenResponseClient()))  // OAuthConfig의 메서드 사용
                        .userInfoEndpoint(userInfo -> userInfo
                                .userService(oAuthConfig.customOAuth2UserService()))  // OAuthConfig의 메서드 사용
                        .successHandler((request, response, authentication) -> {
                            String token = jwtTokenProvider.createToken(authentication.getName(), "ROLE_USER");
                            response.setHeader("Authorization", "Bearer " + token);
                            response.sendRedirect("/success");  // 성공 시 리다이렉트 경로 설정
                        })
                        .failureHandler((request, response, exception) -> {
                            response.sendRedirect("/failure");  // 실패 시 리다이렉트 경로 설정
                        })
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
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
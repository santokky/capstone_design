package com.capstone.quicklendar.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests((requests) -> requests
                        // 로그인, 회원가입 페이지는 인증 없이 접근 가능
                        .requestMatchers("/", "/join", "/resources/**").permitAll()
                        // 그 외의 모든 요청은 인증 필요
                        .anyRequest().authenticated()
                )
                // 로그인 폼 설정
                .formLogin((form) -> form
                        .loginPage("/login") // 사용자 정의 로그인 페이지 설정 (필요한 경우)
                        .permitAll()
                )
                .logout((logout) -> logout.permitAll());

        return http.build();
    }
}

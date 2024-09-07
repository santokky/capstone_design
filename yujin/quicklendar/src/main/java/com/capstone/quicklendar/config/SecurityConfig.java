package com.capstone.quicklendar.config;

import com.capstone.quicklendar.service.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    // 스프링 시큐리티 설정
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)  // CSRF 비활성화 (개발용, 실제 서비스에서는 필요에 따라 활성화)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/register", "/login", "/css/**", "/js/**").permitAll()  // 로그인 및 회원가입 접근 허용
                        .anyRequest().authenticated()  // 그 외의 요청은 인증 필요
                )
                .formLogin(form -> form
                        .loginPage("/login")  // 커스텀 로그인 페이지 경로
                        .defaultSuccessUrl("/home", true)  // 로그인 성공 시 이동할 경로
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/logout")  // 로그아웃 경로
                        .logoutSuccessUrl("/login?logout")  // 로그아웃 성공 시 이동할 경로
                        .permitAll()
                );

        return http.build();
    }

    // 비밀번호 인코더 설정
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // UserDetailsService 설정
    @Bean
    public UserDetailsService userDetailsService(CustomUserDetailsService customUserDetailsService) {
        return customUserDetailsService;
    }

    // AuthenticationManager 설정 (스프링 시큐리티 6.x에서는 필요할 수 있음)
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }
}

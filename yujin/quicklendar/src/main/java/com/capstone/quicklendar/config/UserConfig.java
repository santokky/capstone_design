package com.capstone.quicklendar.config;

import com.capstone.quicklendar.repository.DatabaseUserRepository;
import com.capstone.quicklendar.repository.UserRepository;
import com.capstone.quicklendar.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class UserConfig {

    @Bean
    public UserRepository userRepository() {
        return new DatabaseUserRepository(); // EntityManager 자동으로 주입되므로 파라미터 불필요
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserService userService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return new UserService(userRepository, passwordEncoder);
    }
}

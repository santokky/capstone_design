package com.capstone.quicklendar.config;

import com.capstone.quicklendar.repository.MemoryUserRepository;
import com.capstone.quicklendar.repository.UserRepository;
import com.capstone.quicklendar.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UserConfig {

    @Bean
    public UserRepository userRepository() {
        return new MemoryUserRepository(); // Memory 기반의 UserRepository 빈 설정
    }

    @Bean
    public UserService userService() {
        return new UserService(userRepository()); // UserService <- userRepository 주입
    }
}

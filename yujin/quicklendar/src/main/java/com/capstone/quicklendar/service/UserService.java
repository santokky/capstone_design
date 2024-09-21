package com.capstone.quicklendar.service;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.repository.UserRepository;
import java.util.Optional;

public class UserService {
    private final UserRepository userRepository;

    // 생성자 주입을 통해 의존성 설정
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 회원가입 로직
    public Long register(User user) {
        // 1. 이메일 중복 확인
        Optional<User> existingUser = userRepository.findByEmail(user.getEmail());
        if (existingUser.isPresent()) {
            return user.getId();
        }

        // 2. 새로운 사용자 저장
        userRepository.save(user);
        return user.getId();
    }


    private void validateDuplicateMember(User user) {
        userRepository.findByEmail(user.getEmail())
                .ifPresent(m -> {
                    throw new IllegalStateException("이미 존재하는 회원입니다.");
                });
    }
}

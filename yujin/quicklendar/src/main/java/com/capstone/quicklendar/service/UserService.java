package com.capstone.quicklendar.service;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;
import com.capstone.quicklendar.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.Optional;

public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // 회원가입 로직
    public Long join(User user) {
        // 이메일 중복 확인
        validateDuplicateUser(user);

        // 사용자 유형과 활성화 여부 기본값 설정
        user.setUserType(UserType.LOCAL); // 사용자 유형을 LOCAL로 설정
        user.setEnabled(true); // 기본값으로 활성화 상태 설정 (true)

        // 비밀번호 해싱
        String hashedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(hashedPassword); // 해싱된 비밀번호 저장

        // 사용자 정보 저장
        userRepository.save(user);
        return user.getId();
    }

    private void validateDuplicateUser(User user) {
        userRepository.findByEmail(user.getEmail())
                .ifPresent(m -> {
                    throw new IllegalStateException("이미 존재하는 회원입니다.");
                });
    }
}

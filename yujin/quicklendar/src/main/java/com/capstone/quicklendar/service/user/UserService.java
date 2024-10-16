package com.capstone.quicklendar.service.user;

import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.domain.user.UserType;
import com.capstone.quicklendar.repository.user.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Long join(User user) {
        validateDuplicateUser(user);
        // 비밀번호 해싱
        String encodedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encodedPassword);
        user.setUserType(UserType.LOCAL);
        user.setEnabled(true); // 기본값 활성화
        userRepository.save(user);
        return user.getId();
    }

    private void validateDuplicateUser(User user) {
        userRepository.findByEmail(user.getEmail()).ifPresent(m -> {
            throw new IllegalStateException("이미 존재하는 이메일입니다.");
        });
    }

    // 비밀번호 유효성 검사
    private void validatePassword(String password) {
        if (password.length() < 8) {
            throw new IllegalArgumentException("비밀번호는 최소 8자 이상이어야 합니다.");
        }

        if (!password.matches(".*[A-Z].*")) {
            throw new IllegalArgumentException("비밀번호에는 최소 하나의 대문자가 포함되어야 합니다.");
        }

        if (!password.matches(".*[a-z].*")) {
            throw new IllegalArgumentException("비밀번호에는 최소 하나의 소문자가 포함되어야 합니다.");
        }

        if (!password.matches(".*\\d.*")) {
            throw new IllegalArgumentException("비밀번호에는 최소 하나의 숫자가 포함되어야 합니다.");
        }

        if (!password.matches(".*[!@#\\$%\\^&\\*].*")) {
            throw new IllegalArgumentException("비밀번호에는 최소 하나의 특수문자가 포함되어야 합니다.");
        }
    }

    // 회원 탈퇴 로직
    @Transactional
    public void deleteAccount(Long userId) {
        Optional<User> user = userRepository.findById(userId);

        if (user.isPresent()) {
            userRepository.deleteById(userId);  // 회원 정보 삭제
        } else {
            throw new IllegalArgumentException("해당 회원이 존재하지 않습니다.");
        }
    }

    @Transactional
    public void updateProfile(User user) {
        userRepository.save(user);  // 사용자 정보 업데이트
    }
}

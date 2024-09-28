package com.capstone.quicklendar.service;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;
import com.capstone.quicklendar.repository.UserRepository;
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
}

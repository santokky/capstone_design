package com.capstone.quicklendar.service;

import com.capstone.quicklendar.entity.Authority;
import com.capstone.quicklendar.entity.User;
import com.capstone.quicklendar.entity.UserType;
import com.capstone.quicklendar.dto.UserDto;
import com.capstone.quicklendar.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public User registerUser(UserDto userDto) {
        if (userRepository.existsByUsername(userDto.getUsername())) {
            throw new IllegalArgumentException("Username is already taken.");
        }

        User user = new User();
        user.setUsername(userDto.getUsername());
        user.setPassword(passwordEncoder.encode(userDto.getPassword()));
        user.setUserType(UserType.LOCAL);
        user.setEnabled(true);

        Authority authority = new Authority();
        authority.setUser(user);
        authority.setAuthority("ROLE_USER");
        user.getAuthorities().add(authority);

        return userRepository.save(user);
    }

    public User findByUsername(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }
}

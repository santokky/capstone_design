package com.capstone.quicklendar.service;

import com.capstone.quicklendar.entity.User;
import com.capstone.quicklendar.dto.UserDto;
import com.capstone.quicklendar.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private UserDto userDto;

    @BeforeEach
    void setUp() {
        userDto = new UserDto();
        userDto.setUsername("testUser");
        userDto.setPassword("testPassword");
    }

    @Test
    void testRegisterUser() {
        // 가정 설정: username이 중복되지 않음
        when(userRepository.existsByUsername(userDto.getUsername())).thenReturn(false);

        // 비밀번호 인코딩 모의 설정
        when(passwordEncoder.encode(userDto.getPassword())).thenReturn("encodedPassword");

        // 사용자 저장 시 저장된 사용자 반환
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // 회원가입 실행
        User registeredUser = userService.registerUser(userDto);

        // 회원가입 결과 검증
        assertNotNull(registeredUser);
        assertEquals("testUser", registeredUser.getUsername());
        assertEquals("encodedPassword", registeredUser.getPassword());
        assertTrue(registeredUser.isEnabled());
        assertEquals(1, registeredUser.getAuthorities().size());  // 기본 권한이 추가되었는지 확인
    }

    @Test
    void testRegisterUserWithDuplicateUsername() {
        // 가정 설정: username이 이미 존재함
        when(userRepository.existsByUsername(userDto.getUsername())).thenReturn(true);

        // 예외가 발생하는지 검증
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.registerUser(userDto);
        });

        assertEquals("Username is already taken.", exception.getMessage());
    }
}

package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;
import com.capstone.quicklendar.service.UserService;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

class MemoryUserRepositoryTest {

    MemoryUserRepository repository = new MemoryUserRepository();
    UserService userService = new UserService(repository);

    @Test
    void save() {
        User user = new User();
        user.setEmail("test@gmail.com");

        // 사용자 저장
        repository.save(user);

        // 이메일로 사용자 검색
        Optional<User> result = repository.findByEmail(user.getEmail());

        // 사용자 검색 결과가 존재하는지 확인하고, 동일한지 비교
        assertThat(result).isPresent();
        assertThat(result.get()).isEqualTo(user);
    }

    @Test
    void findByEmail() {
        // 첫 번째 사용자 등록
        User user1 = new User();
        user1.setEmail("test@gmail.com");
        repository.save(user1);

        // 두 번째 사용자 등록
        User user2 = new User();
        user2.setEmail("spring2@gmail.com");
        repository.save(user2);

        // 첫 번째 사용자 검색
        Optional<User> result = repository.findByEmail("test@gmail.com");

        // 검색된 결과가 존재하는지 확인하고, user1과 동일한지 비교
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo(user1.getEmail());
    }
}
package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;

import java.util.List;
import java.util.Optional;

public interface UserRepository {
    User save(User user);

    Optional<User> findByEmail(String email);

    List<User> findAll();

    void deleteByEmail(String email);
}

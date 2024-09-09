package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;

import java.util.*;

public class MemoryUserRepository implements UserRepository {

    private static Map<Long, User> store = new HashMap<>(); // User 저장소
    private static long sequence = 0L; // id 시퀀스

    @Override
    public User save(User user) {
        user.setId(++sequence);
        store.put(user.getId(), user);
        return user;
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return store.values().stream()
                .filter(user -> user.getEmail().equals(email))
                .findAny();
    }

    @Override
    public List<User> findAll() {
        return new ArrayList<>(store.values());
    }

    @Override
    public void deleteByEmail(String email) {
        store.values().removeIf(user -> user.getEmail().equals(email));
    }

    public void clearStore() {
        store.clear(); // store 초기화
    }
}

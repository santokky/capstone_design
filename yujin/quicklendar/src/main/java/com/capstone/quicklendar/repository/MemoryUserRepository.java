package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;

import java.util.*;

public class MemoryUserRepository implements UserRepository {

    private static Map<Long, User> store = new HashMap<>(); // User 저장소
    private static long sequence = 0L; // id 시퀀스

    @Override
    public User save(User user) {
        user.setId(++sequence); // id 자동 증가
        store.put(user.getId(), user); // 저장소에 사용자 저장
        return user;
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return store.values().stream()
                .filter(user -> user.getEmail().equals(email))
                .findAny(); // 이메일로 사용자 검색
    }

    @Override
    public List<User> findAll() {
        return new ArrayList<>(store.values()); // 모든 사용자 반환
    }

    @Override
    public void update(User user) {

    }

    @Override
    public Optional<User> findById(Long id) {
        return Optional.empty();
    }

    @Override
    public void deleteById(Long id) {

    }

    @Override
    public void deleteByEmail(String email) {
        store.values().removeIf(user -> user.getEmail().equals(email)); // 이메일로 사용자 삭제
    }

    @Override
    public List<User> findAllActiveUsers() {
        return List.of();
    }

    @Override
    public List<User> findAllDisabledUsers() {
        return List.of();
    }

    @Override
    public List<User> findAllByUserType(UserType userType) {
        return List.of();
    }

    @Override
    public long countUsers() {
        return 0;
    }

    @Override
    public long countByUserType(UserType userType) {
        return 0;
    }

    public void clearStore() {
        store.clear(); // 저장소 초기화
    }
}
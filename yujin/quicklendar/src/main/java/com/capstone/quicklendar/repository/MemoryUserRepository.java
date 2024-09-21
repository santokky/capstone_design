package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;
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
    public void deleteByEmail(String email) {
        store.values().removeIf(user -> user.getEmail().equals(email)); // 이메일로 사용자 삭제
    }

    public void clearStore() {
        store.clear(); // 저장소 초기화
    }
}
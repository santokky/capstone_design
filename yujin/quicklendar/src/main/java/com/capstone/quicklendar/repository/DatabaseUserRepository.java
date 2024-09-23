package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

public class DatabaseUserRepository implements UserRepository {

    @PersistenceContext
    private EntityManager entityManager; // EntityManager 주입

    // 회원 저장
    @Override
    @Transactional
    public User save(User user) {
        entityManager.persist(user);  // 사용자 저장
        return user;
    }

    // 모든 사용자 조회
    @Override
    public List<User> findAll() {
        return entityManager.createQuery("SELECT u FROM User u", User.class)
                .getResultList();
    }

    // 사용자 정보 업데이트
    @Override
    @Transactional
    public void update(User user) {
        entityManager.merge(user); // 기존 데이터 업데이트
    }

    // ID로 사용자 찾기
    @Override
    public Optional<User> findById(Long id) {
        User user = entityManager.find(User.class, id);
        return Optional.ofNullable(user);
    }

    // 이메일로 사용자 찾기
    @Override
    public Optional<User> findByEmail(String email) {
        List<User> result = entityManager.createQuery(
                        "SELECT u FROM User u WHERE u.email = :email", User.class)
                .setParameter("email", email)
                .getResultList();
        return result.stream().findFirst();
    }

    // ID로 사용자 삭제
    @Override
    @Transactional
    public void deleteById(Long id) {
        User user = entityManager.find(User.class, id);
        if (user != null) {
            entityManager.remove(user);
        }
    }

    // 이메일로 사용자 삭제
    @Override
    @Transactional
    public void deleteByEmail(String email) {
        Optional<User> userOptional = findByEmail(email);
        userOptional.ifPresent(entityManager::remove);
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
}

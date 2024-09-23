package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.domain.UserType;

import java.util.List;
import java.util.Optional;

public interface UserRepository {

    // 사용자 저장
    User save(User user);

    // 모든 사용자 반환
    List<User> findAll();

    // 사용자 정보 업데이트
    void update(User user);

    // ID로 사용자 찾기
    Optional<User> findById(Long id);

    // ID로 사용자 삭제
    void deleteById(Long id);

    // 이메일로 사용자 찾기
    Optional<User> findByEmail(String email);

    // 이메일로 사용자 삭제
    void deleteByEmail(String email);

    // ======= 관리자용 메서드 추가 =======

    // 활성화된 사용자 반환
    List<User> findAllActiveUsers();

    // 비활성화된 사용자 반환
    List<User> findAllDisabledUsers();

    // 특정 사용자 유형(LOCAL 또는 OAUTH) 반환
    List<User> findAllByUserType(UserType userType);

    // 전체 사용자 수 반환
    long countUsers();

    // 특정 사용자 유형의 사용자 수 반환
    long countByUserType(UserType userType);
}

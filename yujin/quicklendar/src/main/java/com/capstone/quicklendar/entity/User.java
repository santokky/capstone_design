package com.capstone.quicklendar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

/**
 * 사용자 정보를 저장하는 엔티티 클래스.
 * 일반 로그인 계정과 OAuth 계정을 구분하여 관리.
 */
@Entity
@Table(name = "users")
@Getter @Setter
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;  // 사용자 고유 ID (기본 키)

    @Column(nullable = false, unique = true)
    private String username;  // 사용자 이름 또는 이메일 (로그인 ID)

    @Column
    private String password;  // 일반 사용자 계정일 때 비밀번호 저장 (OAuth 계정일 경우 null)

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserType userType;  // 사용자 유형 (LOCAL: 일반 로그인, OAUTH: OAuth 로그인)

    @Column(nullable = false)
    private boolean enabled = true;  // 계정 활성화 여부 (기본값은 활성화)

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<Authority> authorities = new HashSet<>();  // 사용자의 권한 목록 (1:N 관계)

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private OAuthAccount oauthAccount;  // OAuth 계정 정보와의 1:1 관계

}


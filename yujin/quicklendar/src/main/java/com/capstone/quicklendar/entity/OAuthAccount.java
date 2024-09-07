package com.capstone.quicklendar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * OAuth 로그인 계정 정보를 저장하는 엔티티 클래스.
 * Google, Naver 등의 OAuth 제공자 정보를 저장.
 */
@Entity
@Table(name = "oauth_accounts")
@Getter @Setter
public class OAuthAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;  // OAuth 계정의 고유 ID

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;  // users 테이블과의 1:1 관계

    @Column(nullable = false)
    private String provider;  // OAuth 제공자 (예: Google, Facebook)

    @Column(nullable = false)
    private String providerUserId;  // 제공자에서 사용하는 사용자 고유 ID

    @Column
    private String accessToken;  // OAuth 액세스 토큰 (필요한 경우 저장)

    @Column
    private String refreshToken;  // OAuth 갱신 토큰 (필요시 저장)

    @Column
    private LocalDateTime expiresAt;  // 토큰 만료 시간 (필요시 저장)

}


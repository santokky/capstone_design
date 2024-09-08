package com.capstone.quicklendar.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    // 기본 키로 설정된 id 필드, 자동 증가 사용
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 사용자 이름 필드, null 허용하지 않음
    @Column(length = 50, nullable = false)
    private String username;

    // 비밀번호 필드, null 허용 (OAuth2 사용자일 경우 password 없을 수 있음)
    @Column(length = 255)
    private String password;

    // userType 필드는 ENUM 타입 (LOCAL 또는 OAUTH), 문자열로 DB에 저장됨, null 허용하지 않음
    @Enumerated(EnumType.STRING)
    @Column(name = "user_type", nullable = false)
    private UserType userType;

    // enabled 필드는 사용자의 활성화 여부를 나타내며, 기본값은 true (1)
    @Column(nullable = false)
    private boolean enabled = true;

    // createdAt 필드는 엔티티가 처음 생성될 때의 시간을 저장, 수정 불가
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    // updatedAt 필드는 엔티티가 수정될 때마다 업데이트 시간 기록
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // 엔티티가 생성되기 전에 createdAt에 현재 시간을 자동으로 설정
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    // 엔티티가 업데이트되기 전에 updatedAt에 현재 시간을 자동으로 설정
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}

// 회원은 LOCAL 또는 OAUTH 값을 가짐
enum UserType {
    LOCAL,
    OAUTH
}
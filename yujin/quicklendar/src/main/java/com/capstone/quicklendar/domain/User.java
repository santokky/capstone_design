package com.capstone.quicklendar.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    // 기본 키로 설정된 id 필드, 자동 증가 사용
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 사용자 이름 필드, null 허용하지 않음
    @Column(length = 255, nullable = false)
    private String name;

    // email 필드는 길이가 255이고, null 허용하지 않고, 고유 값이어야 함
    @Column(length = 255, nullable = false, unique = true)
    private String email;

    // 비밀번호 필드, OAuth2 사용자일 경우 password 없을 수 있음, null 허용
    @Column(length = 255)
    private String password;

    // 전화번호 필드, null 허용
    @Column(length = 20)
    private String phone;

    // OAuth 제공자 이름
    @Column(length = 50)
    private String provider;

    // OAuth 제공자에서 제공하는 사용자의 고유 ID
    @Column(length = 255)
    private String provider_id;

    // 사용자 타입 필드, ENUM 타입 (LOCAL 또는 OAUTH), null 허용하지 않음
    @Enumerated(EnumType.STRING)
    @Column(name = "user_type", nullable = false)
    private UserType userType;

    // 사용자의 활성화 여부, 기본값은 true (1)
    @Column(nullable = false)
    private boolean enabled;

    // 엔티티가 처음 생성될 때의 시간을 저장, 수정 불가
    @Column(name = "created_at", updatable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    // 엔티티가 수정될 때마다 업데이트 시간 기록
    @Column(name = "updated_at", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    private LocalDateTime updatedAt;

    // 엔티티가 생성되기 전에 createdAt에 현재 시간을 자동으로 설정
    @PrePersist
    protected void onCreate() {
        if (createdAt == null) { // 생성 시 한 번만 시간 설정
            createdAt = LocalDateTime.now();
        }
    }

    // 엔티티가 업데이트되기 전에 updatedAt에 현재 시간을 자동으로 설정
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // getter and setter
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProvider_id() {
        return provider_id;
    }

    public void setProvider_id(String provider_id) {
        this.provider_id = provider_id;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}


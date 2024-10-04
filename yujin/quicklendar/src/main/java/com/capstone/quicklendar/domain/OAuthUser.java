package com.capstone.quicklendar.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "oauth_users")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OAuthUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 50, nullable = false)
    private String provider; // 소셜 로그인 제공자 (예: google, naver)

    @Column(length = 255, nullable = false, unique = true)
    private String providerId; // 소셜 로그인 제공자의 사용자 ID

    @OneToOne
    @JoinColumn(name = "user_id")
    private User user; // User 엔티티와 연결 (일대일 관계)

    // 생성자, getter, setter

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}

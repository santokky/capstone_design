package com.capstone.quicklendar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;

/**
 * 사용자의 권한 정보를 저장하는 엔티티 클래스.
 * 각 사용자는 하나 이상의 권한을 가질 수 있습니다.
 */
@Entity
@Table(name = "authorities")
@Getter @Setter
public class Authority implements GrantedAuthority {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;  // 권한의 고유 ID

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;  // users 테이블과의 N:1 관계

    @Column(nullable = false)
    private String authority;  // 권한 이름 (예: ROLE_USER, ROLE_ADMIN)

}


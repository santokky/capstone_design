package com.capstone.quicklendar.domain;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.List;

public class CustomUserDetails implements UserDetails {

    private final User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    public User getUser() {
        return user;
    }

    public Long getId() {
        return user.getId();
    }

    @Override
    public String getUsername() {
        return user.getEmail();  // Spring Security에서 username으로 이메일 사용
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public boolean isEnabled() {
        return user.isEnabled();
    }

    // 계정 만료 여부 설정
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    // 계정 잠금 여부 설정
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    // 비밀번호 만료 여부 설정
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    // 권한 정보 반환 (필요에 따라 변경 가능)
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 여기서 ROLE_USER만을 반환할 수 있으며, 필요 시 더 많은 권한을 설정 가능
        return List.of(() -> "ROLE_USER");
    }

    // 추가로 `User`의 다른 필드를 필요할 때 가져오는 메서드도 추가 가능
    public String getName() {
        return user.getName();
    }

    public String getPhone() {
        return user.getPhone();
    }
}

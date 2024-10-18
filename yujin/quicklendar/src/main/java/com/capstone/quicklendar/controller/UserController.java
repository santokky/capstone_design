package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.user.CustomOAuth2User;
import com.capstone.quicklendar.domain.user.CustomUserDetails;
import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.service.user.CustomOAuth2UserService;
import com.capstone.quicklendar.service.user.UserService;
import com.capstone.quicklendar.util.dto.OAuthLoginRequest;
import com.capstone.quicklendar.util.dto.OAuthUnlinkRequest;
import com.capstone.quicklendar.util.dto.UpdateProfileRequest;
import com.capstone.quicklendar.util.jwt.JwtAuthenticationResponse;
import com.capstone.quicklendar.util.jwt.JwtTokenProvider;
import com.capstone.quicklendar.util.dto.LoginRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.stream.Collectors;
import com.capstone.quicklendar.domain.user.Role;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final CustomOAuth2UserService customOAuth2UserService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public UserController(UserService userService, CustomOAuth2UserService customOAuth2UserService,
                          AuthenticationManager authenticationManager, JwtTokenProvider jwtTokenProvider) {
        this.userService = userService;
        this.customOAuth2UserService = customOAuth2UserService;
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 회원가입 처리 (POST)
    @PostMapping("/join")
    public ResponseEntity<?> join(@RequestBody User user) {
        try {
            userService.join(user);
            return ResponseEntity.ok("회원가입이 완료되었습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // 로그인 처리 (POST)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword())
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);

            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();

            String roles = userDetails.getUser().getRoles().stream()
                    .map(Role::getName)
                    .collect(Collectors.joining(","));

            String token = jwtTokenProvider.createToken(userDetails.getUsername(), roles);

            return ResponseEntity.ok(new JwtAuthenticationResponse(token));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
        }
    }

    // 회원 탈퇴 처리 (DELETE)
    @DeleteMapping("/{userId}")
    public ResponseEntity<?> deleteAccount(@PathVariable("userId") Long userId) {
        try {
            // 인증 정보 가져오기
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

            if (authentication != null) {
                // 일반 사용자 탈퇴 처리
                if (authentication.getPrincipal() instanceof CustomUserDetails) {
                    CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
                    if (userDetails.getId().equals(userId)) {
                        // 현재 인증된 사용자와 탈퇴하려는 userId가 동일한지 확인
                        userService.deleteAccount(userId);
                        return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
                    } else {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("탈퇴 권한이 없습니다.");
                    }
                }

                // OAuth 사용자 탈퇴 처리
                if (authentication.getPrincipal() instanceof CustomOAuth2User) {
                    CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();
                    User user = oauthUser.getUser();

                    if (user.getId().equals(userId)) {
                        String providerId = user.getProvider_id();
                        String provider = user.getProvider();

                        if (providerId != null && provider != null) {
                            customOAuth2UserService.unlinkOAuthUser(providerId, provider);
                            return ResponseEntity.ok("OAuth 연동 해제가 완료되었습니다.");
                        } else {
                            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("OAuth 사용자 정보가 유효하지 않습니다.");
                        }
                    } else {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("탈퇴 권한이 없습니다.");
                    }
                }
            }

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("인증 정보가 유효하지 않습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("회원 탈퇴 처리 중 오류가 발생했습니다.");
        }
    }

    // 프로필 조회 (GET)
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            return ResponseEntity.ok(userDetails.getUser());
        } else if (authentication != null && authentication.getPrincipal() instanceof CustomOAuth2User) {
            CustomOAuth2User oAuth2User = (CustomOAuth2User) authentication.getPrincipal();
            return ResponseEntity.ok(oAuth2User.getUser());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("인증 정보가 유효하지 않습니다.");
        }
    }

    // 프로필 업데이트 (PUT)
    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody UpdateProfileRequest updateProfileRequest) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
                User user = userDetails.getUser();

                // 입력 받은 정보로 사용자 정보 업데이트
                user.setName(updateProfileRequest.getName());
                user.setPhone(updateProfileRequest.getPhone());
                if (updateProfileRequest.getPassword() != null && !updateProfileRequest.getPassword().isEmpty()) {
                    user.setPassword(passwordEncoder.encode(updateProfileRequest.getPassword()));
                }

                userService.updateProfile(user);
                return ResponseEntity.ok("프로필이 성공적으로 업데이트되었습니다.");
            }
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("인증 정보가 유효하지 않습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("프로필 업데이트 중 오류가 발생했습니다.");
        }
    }

    @GetMapping("/api/users/oauth2/login/naver")
    public ResponseEntity<?> naverLoginCallback(@RequestParam String code, @RequestParam String state) {
        try {
            // 네이버로부터 액세스 토큰 요청
            String accessToken = customOAuth2UserService.getAccessToken(code, state);

            // 액세스 토큰으로 사용자 정보 요청
            Map<String, Object> userProfile = customOAuth2UserService.getNaverUserProfile(accessToken);
            String email = (String) userProfile.get("email");

            // JWT 토큰 생성
            String token = jwtTokenProvider.createToken(email, "ROLE_USER");

            return ResponseEntity.ok(new JwtAuthenticationResponse(token));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }

    @PostMapping("/oauth2/login/naver")
    public ResponseEntity<?> naverLogin(@RequestBody Map<String, String> body) {
        try {
            String authorizationCode = body.get("code");
            String state = body.get("state");

            // 네이버로부터 액세스 토큰 요청
            String accessToken = customOAuth2UserService.getAccessToken(authorizationCode, state);

            // 액세스 토큰으로 사용자 정보 요청
            Map<String, Object> userProfile = customOAuth2UserService.getNaverUserProfile(accessToken);
            String email = (String) userProfile.get("email");

            // JWT 토큰 생성
            String token = jwtTokenProvider.createToken(email, "ROLE_USER");

            return ResponseEntity.ok(new JwtAuthenticationResponse(token));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }

    // OAuth 연동 해제 (DELETE)
    @DeleteMapping("/oauth/unlink")
    public ResponseEntity<?> unlinkOAuthUser(@RequestBody OAuthUnlinkRequest unlinkRequest) {
        try {
            customOAuth2UserService.unlinkOAuthUser(unlinkRequest.getProviderId(), unlinkRequest.getProvider());
            return ResponseEntity.ok("OAuth 연동 해제가 완료되었습니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("OAuth 연동 해제 중 오류가 발생했습니다.");
        }
    }
}

package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.user.CustomUserDetails;
import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.service.user.CustomOAuth2UserService;
import com.capstone.quicklendar.service.user.UserService;
import com.capstone.quicklendar.util.dto.JwtResponse;
import com.capstone.quicklendar.util.dto.LoginRequest;
import com.capstone.quicklendar.util.dto.SignUpRequest;
import com.capstone.quicklendar.util.jwt.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.security.core.GrantedAuthority;

@RestController
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

    // 회원가입 처리 - JSON
    @PostMapping("/signup")
    public ResponseEntity<String> signupUser(@RequestBody SignUpRequest signUpRequest) {
        try {
            User user = new User();
            user.setEmail(signUpRequest.getEmail());
            user.setPassword(signUpRequest.getPassword());
            user.setName(signUpRequest.getName());
            user.setPhone(signUpRequest.getPhone());

            Long userId = userService.join(user);

            return ResponseEntity.status(HttpStatus.CREATED).body("회원가입이 완료되었습니다. User ID: " + userId);
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("이미 존재하는 이메일입니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("회원가입 중 오류가 발생했습니다.");
        }
    }

    // 로그인 처리 - JWT 발급
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getEmail(), loginRequest.getPassword()
                    )
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            String roles = authentication.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.joining(","));

            User user = ((CustomUserDetails) authentication.getPrincipal()).getUser();
            String jwt = jwtTokenProvider.createToken(authentication.getName(), roles);

            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Bearer " + jwt);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(new JwtResponse(jwt, "Bearer", user.getName(), user.getEmail()));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인 실패: 잘못된 이메일 또는 비밀번호입니다.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("로그인 처리 중 오류가 발생했습니다.");
        }
    }

    // 로그아웃 처리
    @PostMapping("/logout")
    public ResponseEntity<?> logoutUser() {
        return ResponseEntity.ok("로그아웃 성공");
    }

    // 네이버 로그인 처리 - 인증코드 받아오기
    @GetMapping("/oauth2/login/naver")
    public ResponseEntity<?> naverLoginCallback(@RequestParam("code") String code, @RequestParam("state") String state) {
        try {
            String accessToken = customOAuth2UserService.getAccessToken("naver", code, state);

            Map<String, Object> userProfile = customOAuth2UserService.getNaverUserProfile(accessToken);
            String email = (String) userProfile.get("email");

            String token = jwtTokenProvider.createToken(email, "ROLE_USER");

            return ResponseEntity.ok(new JwtResponse(token));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }

    // 네이버 로그인 처리 - JSON 응답
    @PostMapping("/oauth2/login/naver")
    public ResponseEntity<?> naverLogin(@RequestBody Map<String, String> body) {
        try {
            String code = body.get("code");
            String state = body.get("state");

            String accessToken = customOAuth2UserService.getAccessToken("naver", code, state);
            Map<String, Object> userProfile = customOAuth2UserService.getNaverUserProfile(accessToken);

            String email = (String) userProfile.get("email");
            String jwt = jwtTokenProvider.createToken(email, "ROLE_USER");

            Map<String, String> response = new HashMap<>();
            response.put("token", jwt);
            response.put("email", email);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }

    // 구글 로그인 처리
    @PostMapping("/oauth2/login/google")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> body) {
        try {
            String code = body.get("code");
            String accessToken = customOAuth2UserService.getAccessToken("google", code, null);

            // 구글 사용자 프로필 가져오기
            Map<String, Object> userProfile = customOAuth2UserService.getGoogleUserProfile(accessToken);
            String email = (String) userProfile.get("email");

            String jwt = jwtTokenProvider.createToken(email, "ROLE_USER");

            Map<String, String> response = new HashMap<>();
            response.put("token", jwt);
            response.put("email", email);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }
}

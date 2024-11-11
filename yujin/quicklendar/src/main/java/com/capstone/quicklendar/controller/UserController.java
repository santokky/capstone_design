package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.user.CustomOAuth2User;
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
import org.springframework.ui.Model;
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

    @Autowired
    private PasswordEncoder passwordEncoder;

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

    // 네이버 로그인 처리 - 로그인 검증
    @PostMapping("/oauth2/login/naver")
    public ResponseEntity<?> naverLogin(@RequestBody Map<String, String> body) {
        try {
            String authorizationCode = body.get("code");
            String state = body.get("state");

            String accessToken = customOAuth2UserService.getAccessToken("naver", authorizationCode, state);

            Map<String, Object> userProfile = customOAuth2UserService.getNaverUserProfile(accessToken);
            String email = (String) userProfile.get("email");
            String name = (String) userProfile.get("name");

            String jwtToken = jwtTokenProvider.createToken(email, "ROLE_USER");

            Map<String, String> response = new HashMap<>();
            response.put("token", jwtToken);
            response.put("name", name);
            response.put("email", email);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("OAuth2 로그인 실패: " + e.getMessage());
        }
    }



    // 회원 탈퇴 처리 POST 요청 (일반 사용자 + OAuth 사용자)
    @PostMapping("/delete-account")
    public String deleteAccount(@RequestParam("userId") Long userId, Model model) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null) {
            if (authentication.getPrincipal() instanceof CustomUserDetails) {
                // 일반 사용자 탈퇴 처리
                userService.deleteAccount(userId);
                model.addAttribute("message", "회원 탈퇴가 완료되었습니다.");
            } else if (authentication.getPrincipal() instanceof CustomOAuth2User) {
                // OAuth 사용자 연동 해제 처리
                CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();
                User user = oauthUser.getUser();  // Users 테이블에서 가져온 User 엔티티 사용
                String providerId = user.getProvider_id();  // Users 테이블에서 저장된 providerId 사용
                String provider = user.getProvider();       // Users 테이블에서 저장된 provider 사용

                if (providerId != null && provider != null) {
                    try {
                        customOAuth2UserService.unlinkOAuthUser(providerId, provider);  // 연동 해제
                        model.addAttribute("message", "연동 해제가 완료되었습니다.");
                    } catch (Exception e) {
                        model.addAttribute("error", "연동 해제 중 오류가 발생했습니다.");
                        return "users/delete-account";  // 연동 해제 실패 시 다시 탈퇴 페이지로
                    }
                } else {
                    model.addAttribute("error", "OAuth 사용자 정보가 유효하지 않습니다.");
                    return "users/delete-account";  // 오류가 있을 시 다시 탈퇴 페이지로
                }
            }
        } else {
            model.addAttribute("error", "인증 정보가 유효하지 않습니다.");
            return "users/delete-account";  // 인증 실패 시 다시 탈퇴 페이지로
        }

        return "redirect:/";  // 탈퇴 후 메인 페이지로 리다이렉트
    }

    // 회원 탈퇴 페이지 GET 요청
    @GetMapping("/delete-account")
    public String showDeleteAccountPage(Model model) {Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            model.addAttribute("userId", userDetails.getId());  // userId를 모델에 추가
            model.addAttribute("user", userDetails.getUser());  // 일반 사용자 user 객체 모델에 추가
        } else if (authentication != null && authentication.getPrincipal() instanceof CustomOAuth2User) {
            CustomOAuth2User oauthUserDetails = (CustomOAuth2User) authentication.getPrincipal();
            model.addAttribute("user", oauthUserDetails.getUser());  // OAuth 사용자의 user 객체 모델에 추가
        }

        return "users/delete-account";  // 삭제 페이지로 이동
    }

    @PostMapping("/unlink-oauth")
    public String unlinkOAuthUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getPrincipal() instanceof CustomOAuth2User) {
            CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();

            // providerId와 provider 정보 추출
            User user = oauthUser.getUser(); // 사용자 정보 가져오기
            String providerId = user.getProvider_id(); // Users 테이블에서 가져온 providerId
            String provider = user.getProvider(); // Users 테이블에서 가져온 provider

            if (providerId != null && provider != null) {
                customOAuth2UserService.unlinkOAuthUser(providerId, provider);
            } else {
                throw new IllegalArgumentException("OAuth 사용자 정보가 유효하지 않습니다.");
            }
        }

        return "redirect:/";
    }

    @PostMapping("/unlink-google")
    public String unlinkGoogleAccount(@RequestParam("userId") Long userId, Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getPrincipal() instanceof CustomOAuth2User) {
            CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();
            String providerId = oauthUser.getProviderId();
            String provider = "google";

            customOAuth2UserService.unlinkOAuthUser(providerId, provider);
        }

        // 로그아웃 후 로그인 페이지로 리다이렉트
        return "redirect:/login";
    }

    // 네이버 연동 해제 처리 POST 요청
    @PostMapping("/unlink-naver")
    public String unlinkNaverAccount(@RequestParam("userId") Long userId, Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getPrincipal() instanceof CustomOAuth2User) {
            CustomOAuth2User oauthUser = (CustomOAuth2User) authentication.getPrincipal();
            String providerId = oauthUser.getProviderId();
            String provider = "naver"; // 네이버로 provider 설정

            try {
                customOAuth2UserService.unlinkOAuthUser(providerId, provider);
                model.addAttribute("message", "네이버 연동 해제가 완료되었습니다.");
            } catch (Exception e) {
                model.addAttribute("error", "네이버 연동 해제 중 오류가 발생했습니다.");
                return "users/delete-account";  // 연동 해제 실패 시 다시 탈퇴 페이지로 이동
            }
        }

        // 연동 해제 후 로그인 페이지로 리다이렉트
        return "redirect:/login";
    }
}
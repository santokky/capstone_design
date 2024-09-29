package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.CustomUserDetails;
import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 메인 페이지
    @GetMapping("/")
    public String index() {
        return "index";
    }

    // 회원가입 페이지 GET 요청
    @GetMapping("/join")
    public String showJoinForm(Model model) {
        model.addAttribute("user", new User());
        return "users/join"; // join.html 렌더링
    }

    // 회원가입 처리 POST 요청
    @PostMapping("/join")
    public String join(User user, Model model) {
        try {
            userService.join(user); // 회원가입 로직 실행
            model.addAttribute("message", "회원가입이 완료되었습니다.");
            return "redirect:/login"; // 회원가입 후 로그인 페이지로 리다이렉트
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "users/join"; // 오류 발생 시 다시 회원가입 페이지로 이동
        }
    }

    // 로그인 페이지 GET 요청
    @GetMapping("/login")
    public String showLoginForm() {
        return "users/login"; // login.html 렌더링
    }

    @PostMapping("/delete-account")
    public String deleteAccount(@RequestParam("userId") Long userId, Model model) {
        try {
            // userId 값이 제대로 전달되는지 확인하는 로깅 추가
            System.out.println("탈퇴할 사용자 ID: " + userId);
            userService.deleteAccount(userId);
            model.addAttribute("message", "회원 탈퇴가 완료되었습니다.");
            return "redirect:/";  // 탈퇴 후 메인 페이지로 리다이렉트
        } catch (Exception e) {
            model.addAttribute("error", "회원 탈퇴 중 문제가 발생했습니다: " + e.getMessage());
            return "users/profile";  // 탈퇴 실패 시 프로필 페이지로 돌아감
        }
    }

    @GetMapping("/delete-account")
    public String showDeleteAccountPage(Model model) {
        // 현재 인증된 사용자 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            model.addAttribute("userId", userDetails.getId());  // userId를 모델에 추가
        }
        return "users/delete-account";  // 삭제 페이지로 이동
    }

    @GetMapping("/profile")
    public String showProfilePage(Model model) {
        // 현재 인증된 사용자 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            model.addAttribute("user", userDetails);  // user 정보 추가
        }
        return "users/profile";  // profile.html로 이동
    }

    @PostMapping("/profile")
    public String updateProfile(@RequestParam("name") String name,
                                @RequestParam("phone") String phone,
                                @RequestParam("password") String password,
                                Model model) {
        // 현재 인증된 사용자 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            User user = userDetails.getUser();

            // 입력 받은 정보로 사용자 정보 업데이트
            user.setName(name);
            user.setPhone(phone);
            if (!password.isEmpty()) {
                user.setPassword(passwordEncoder.encode(password));
            }

            // 업데이트된 사용자 정보 저장
            userService.updateProfile(user);

            model.addAttribute("message", "프로필이 성공적으로 업데이트되었습니다.");
        }

        return "redirect:/profile";  // 업데이트 후 다시 프로필 페이지로 리다이렉트
    }

    @GetMapping("/logout-page")
    public String showLogoutPage() {
        return "users/logout";
    }
}

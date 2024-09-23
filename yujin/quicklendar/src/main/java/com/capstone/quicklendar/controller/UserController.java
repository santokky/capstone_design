package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.User;
import com.capstone.quicklendar.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    // 메인 페이지
    @GetMapping("/")
    public String index() {
        return "index"; // index.html 렌더링
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
            // 회원가입 로직 처리
            userService.join(user);

            model.addAttribute("message", "회원가입이 완료되었습니다.");
            return "redirect:/"; // 메인 페이지로 리다이렉트
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "users/join"; // 오류 시 다시 회원가입 페이지로
        }
    }
}

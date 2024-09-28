package com.capstone.quicklendar;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BCryptPasswordChecker {

    public static void main(String[] args) {
        // 해시된 비밀번호 (BCrypt로 인코딩된 값)
        String hashedPassword = "$2a$10$tlCseIzYM6LhtWQ7drNjV.cwhfxsSNJnzUjyeGMcZpefxG2TCo2ae";

        // 확인하고자 하는 원래 비밀번호
        String rawPassword = "1234"; // 여기서 원래 비밀번호를 입력

        // BCryptPasswordEncoder 인스턴스 생성
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // 입력된 비밀번호가 해시된 비밀번호와 일치하는지 확인
        boolean isMatch = encoder.matches(rawPassword, hashedPassword);

        if (isMatch) {
            System.out.println("비밀번호가 일치합니다.");
        } else {
            System.out.println("비밀번호가 일치하지 않습니다.");
        }
    }
}

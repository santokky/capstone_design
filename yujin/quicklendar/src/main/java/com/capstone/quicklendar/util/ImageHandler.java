package com.capstone.quicklendar.util;

import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
public class ImageHandler {

    public String saveImage(MultipartFile imageFile, String uploadDir) throws IOException {
        if (!imageFile.isEmpty()) {
            String fileName = imageFile.getOriginalFilename();
            Path uploadPath = Paths.get(uploadDir);

            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);  // 디렉터리 없으면 생성
            }

            Path filePath = uploadPath.resolve(fileName);  // 저장할 파일의 전체 경로
            imageFile.transferTo(filePath.toFile());  // 파일 저장

            // 경로를 반환
            return "/images/" + fileName;  // 저장된 파일 경로 반환
        }
        return null;
    }
}

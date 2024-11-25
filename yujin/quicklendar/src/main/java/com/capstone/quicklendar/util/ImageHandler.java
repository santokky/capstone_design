package com.capstone.quicklendar.util;

import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
public class ImageHandler {
    public String saveImage(MultipartFile imageFile, String uploadDir) throws IOException {
        if (!imageFile.isEmpty()) {
            File directory = new File(uploadDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            String fileName = System.currentTimeMillis() + "-" + imageFile.getOriginalFilename();
            Path filePath = Paths.get(uploadDir, fileName);

            imageFile.transferTo(filePath.toFile());

            return fileName;
        }
        return null;
    }
}

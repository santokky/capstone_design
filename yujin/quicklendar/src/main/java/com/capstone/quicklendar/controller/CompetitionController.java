package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import com.capstone.quicklendar.service.competition.CompetitionLikeService;
import com.capstone.quicklendar.service.competition.CompetitionService;
import com.capstone.quicklendar.util.dto.CompetitionDTO;
import com.capstone.quicklendar.util.dto.CompetitionFormDTO;
import com.capstone.quicklendar.util.ImageHandler;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/competitions")
public class CompetitionController {

    private final CompetitionService competitionService;
    private final CompetitionLikeService competitionLikeService;
    private final ImageHandler imageHandler;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Value("${image.base.url}")
    private String imageBaseUrl;

    @Autowired
    public CompetitionController(CompetitionService competitionService,
                                 CompetitionLikeService competitionLikeService,
                                 ImageHandler imageHandler) {
        this.competitionService = competitionService;
        this.competitionLikeService = competitionLikeService;
        this.imageHandler = imageHandler;
    }

    // 공모전 목록 조회
    @GetMapping(produces = "application/json; charset=UTF-8")
    public ResponseEntity<List<CompetitionDTO>> getAllCompetitions(
            @RequestParam(value = "category", required = false) String categoryStr,
            @RequestParam(value = "competitionType", required = false) String competitionTypeStr,
            @RequestParam(value = "host", required = false) String host) {
        Category category = (categoryStr != null) ? Category.valueOf(categoryStr.toUpperCase()) : null;
        CompetitionType competitionType = (competitionTypeStr != null) ? CompetitionType.valueOf(competitionTypeStr.toUpperCase()) : null;

        List<CompetitionDTO> competitions = competitionService.filterCompetitions(category, competitionType, host)
                .stream()
                .map(competition -> new CompetitionDTO(competition, imageBaseUrl))
                .collect(Collectors.toList());

        return ResponseEntity.ok(competitions);
    }

    // 공모전 상세 정보 조회
    @GetMapping("/details/{id}")
    public ResponseEntity<CompetitionDTO> getCompetition(@PathVariable Long id) {
        Competition competition = competitionService.getCompetitionById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition ID: " + id));

        return ResponseEntity.ok(new CompetitionDTO(competition, imageBaseUrl));
    }

    // 공모전 등록
    @PostMapping(path = "/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<CompetitionDTO> addCompetition(
            @RequestPart("competition") CompetitionFormDTO competitionFormDTO,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {
        try {
            String imagePath = saveImageIfPresent(imageFile);

            Competition competition = mapFormDTOToEntity(competitionFormDTO, imagePath);

            Competition savedCompetition = competitionService.addCompetition(competition);

            return ResponseEntity.status(HttpStatus.CREATED).body(new CompetitionDTO(savedCompetition, imageBaseUrl));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestPart("file") MultipartFile file) {
        try {
            File directory = new File(uploadDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            String fileName = System.currentTimeMillis() + "-" + file.getOriginalFilename();
            Path filePath = Paths.get(uploadDir, fileName);

            file.transferTo(filePath.toFile());

            String fileUrl = imageBaseUrl + "/" + fileName;

            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", fileUrl);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // 헬퍼 메서드: 이미지 저장 처리
    private String saveImageIfPresent(MultipartFile imageFile) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            return imageHandler.saveImage(imageFile, uploadDir);
        }
        return null;
    }

    // 헬퍼 메서드: DTO -> Entity 변환
    private Competition mapFormDTOToEntity(CompetitionFormDTO dto, String imagePath) {
        Competition competition = new Competition();
        competition.setName(dto.getName());
        competition.setDescription(dto.getDescription());
        competition.setStartDate(dto.getStartDate());
        competition.setEndDate(dto.getEndDate());
        competition.setRequestStartDate(dto.getRequestStartDate());
        competition.setRequestEndDate(dto.getRequestEndDate());
        competition.setRequestPath(dto.getRequestPath());
        competition.setLocation(dto.getLocation());
        competition.setSupport(dto.getSupport());
        competition.setHost(dto.getHost());
        competition.setCategory(dto.getCategory());
        competition.setCompetitionType(dto.getCompetitionType());
        competition.setImage(imagePath);
        return competition;
    }

    // 공모전 삭제
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteCompetition(@PathVariable Long id) {
        competitionService.deleteCompetition(id);
        return ResponseEntity.noContent().build();
    }

    // 좋아요 추가
    @PostMapping("/{id}/likes")
    public ResponseEntity<Void> likeCompetition(@PathVariable Long id, @RequestParam String userEmail) {
        competitionLikeService.likeCompetition(id, userEmail);
        return ResponseEntity.ok().build();
    }

    // 좋아요 취소
    @DeleteMapping("/{id}/likes")
    public ResponseEntity<Void> unlikeCompetition(@PathVariable Long id, @RequestParam String userEmail) {
        competitionLikeService.unlikeCompetition(id, userEmail);
        return ResponseEntity.noContent().build();
    }

    // 좋아요 여부 확인
    @GetMapping("/{id}/likes")
    public ResponseEntity<Boolean> isLiked(@PathVariable Long id, @RequestParam String userEmail) {
        boolean liked = competitionLikeService.isLiked(id, userEmail);
        return ResponseEntity.ok(liked);
    }

    // 공모전 수정
    @PutMapping("/update/{id}")
    public ResponseEntity<CompetitionDTO> updateCompetition(
            @PathVariable Long id,
            @ModelAttribute CompetitionFormDTO competitionFormDTO) {
        try {
            String imagePath = null;
            if (competitionFormDTO.getImage() != null && !competitionFormDTO.getImage().isEmpty()) {
                imagePath = imageHandler.saveImage(competitionFormDTO.getImage(), uploadDir);
            }

            Competition updatedCompetition = competitionService.updateCompetition(id, competitionFormDTO, imagePath);
            return ResponseEntity.ok(new CompetitionDTO(updatedCompetition, imageBaseUrl));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

}

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
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/competitions")
public class CompetitionController {

    private final CompetitionService competitionService;
    private final CompetitionLikeService competitionLikeService;
    private final ImageHandler imageHandler;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Autowired
    public CompetitionController(CompetitionService competitionService,
                                 CompetitionLikeService competitionLikeService,
                                 ImageHandler imageHandler) {
        this.competitionService = competitionService;
        this.competitionLikeService = competitionLikeService;
        this.imageHandler = imageHandler;
    }

    // 공모전 목록 조회
    @GetMapping
    public ResponseEntity<List<CompetitionDTO>> getAllCompetitions(
            @RequestParam(value = "category", required = false) String categoryStr,
            @RequestParam(value = "competitionType", required = false) String competitionTypeStr,
            @RequestParam(value = "host", required = false) String host) {
        Category category = (categoryStr != null) ? Category.valueOf(categoryStr.toUpperCase()) : null;
        CompetitionType competitionType = (competitionTypeStr != null) ? CompetitionType.valueOf(competitionTypeStr.toUpperCase()) : null;

        List<CompetitionDTO> competitions = competitionService.filterCompetitions(category, competitionType, host)
                .stream()
                .map(CompetitionDTO::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(competitions);
    }

    // 공모전 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<CompetitionDTO> getCompetition(@PathVariable Long id) {
        Competition competition = competitionService.getCompetitionById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition ID: " + id));

        return ResponseEntity.ok(new CompetitionDTO(competition));
    }

    // 공모전 등록
    @PostMapping("/register")
    public ResponseEntity<CompetitionDTO> addCompetition(@RequestBody CompetitionFormDTO competitionFormDTO) {
        try {
            String imagePath = null;
            if (competitionFormDTO.getImage() != null && !competitionFormDTO.getImage().isEmpty()) {
                imagePath = imageHandler.saveImage(competitionFormDTO.getImage(), uploadDir);
            }

            Competition competition = new Competition();
            BeanUtils.copyProperties(competitionFormDTO, competition);
            competition.setImage(imagePath);

            Competition savedCompetition = competitionService.addCompetition(competition);

            return ResponseEntity.status(HttpStatus.CREATED).body(new CompetitionDTO(savedCompetition));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 공모전 삭제
    @DeleteMapping("/{id}")
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
}

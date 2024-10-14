package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import com.capstone.quicklendar.service.competition.CompetitionLikeService;
import com.capstone.quicklendar.service.competition.CompetitionService;
import com.capstone.quicklendar.util.CompetitionFormDTO;
import com.capstone.quicklendar.util.ImageHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.Principal;
import java.util.List;

@Controller
@RequestMapping("/competitions")
public class CompetitionController {

    private static final Logger logger = LoggerFactory.getLogger(CompetitionController.class);

    private final CompetitionService competitionService;
    private final CompetitionLikeService competitionLikeService;
    private final ImageHandler imageHandler;

    @Autowired
    public CompetitionController(CompetitionService competitionService, CompetitionLikeService competitionLikeService, ImageHandler imageHandler) {
        this.competitionService = competitionService;
        this.competitionLikeService = competitionLikeService;  // CompetitionLikeService 주입
        this.imageHandler = imageHandler;
    }

    @Value("${image.upload.dir}")
    private String uploadDir;

    // 공모전 메인 페이지 (공모전 목록 조회)
    @GetMapping("/main")
    public String getCompetitions(@RequestParam(value = "sort", required = false) String sort, Model model) {
        List<Competition> competitions;

        if ("likes".equals(sort)) {
            competitions = competitionService.getCompetitionsSortedByLikes();  // 좋아요 순 정렬
        } else if ("createdAt".equals(sort)) {
            competitions = competitionService.getCompetitionsSortedByCreatedAt();  // 등록일 순 정렬
        } else {
            competitions = competitionService.getAllCompetitions();  // 기본 정렬
        }

        List<String> hosts = competitionService.getAllHosts();  // host 목록 조회
        model.addAttribute("competitions", competitions);
        model.addAttribute("hosts", hosts);  // 필터링을 위한 host 목록 전달
        return "competitions/main";
    }

    // 공모전 상세 페이지
    @GetMapping("/details/{id}")
    public String showCompetitionDetail(@PathVariable("id") Long id, Principal principal, Model model) {
        // 공모전 정보를 조회
        Competition competition = competitionService.getCompetitionById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition Id:" + id));

        // 현재 로그인한 사용자의 이메일을 통해 좋아요 여부 확인
        boolean isLiked = false;
        if (principal != null) {
            String userEmail = principal.getName();
            isLiked = competitionLikeService.isLiked(id, userEmail);  // 좋아요 여부 확인
        }

        // 공모전 정보와 좋아요 여부를 모델에 추가
        model.addAttribute("competition", competition);
        model.addAttribute("isLiked", isLiked);

        // 상세 페이지로 이동
        return "competitions/details";
    }

    // 공모전 추가 페이지
    @GetMapping("/addCompetition")
    public String showAddCompetitionForm(Model model) {
        model.addAttribute("competition", new Competition());
        return "competitions/addCompetition";  // 공모전 추가 페이지 템플릿
    }

    // 공모전 추가 요청 처리
    @PostMapping("/addCompetition")
    public String addCompetition(@ModelAttribute CompetitionFormDTO competitionFormDTO,
                                 BindingResult result, Model model) {
        if (result.hasErrors()) {
            model.addAttribute("competition", competitionFormDTO);
            return "competitions/addCompetition";
        }

        try {
            String savedImagePath = null;
            MultipartFile imageFile = competitionFormDTO.getImage();

            // 파일 저장 처리
            if (!imageFile.isEmpty()) {
                String filename = imageFile.getOriginalFilename();  // 파일 이름 추출
                Path filePath = Paths.get(uploadDir, filename);     // 저장할 경로 생성
                Files.copy(imageFile.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);  // 파일 저장
                savedImagePath = filename;  // 경로 없이 파일명만 저장
            }

            // Competition 엔티티로 데이터 변환
            Competition competition = new Competition();
            competition.setName(competitionFormDTO.getName());
            competition.setDescription(competitionFormDTO.getDescription());
            competition.setStartDate(competitionFormDTO.getStartDate());
            competition.setEndDate(competitionFormDTO.getEndDate());
            competition.setRequestStartDate(competitionFormDTO.getRequestStartDate());
            competition.setRequestEndDate(competitionFormDTO.getRequestEndDate());
            competition.setRequestPath(competitionFormDTO.getRequestPath());
            competition.setLocation(competitionFormDTO.getLocation());
            competition.setHost(competitionFormDTO.getHost());
            competition.setCategory(competitionFormDTO.getCategory());
            competition.setCompetitionType(competitionFormDTO.getCompetitionType());
            competition.setSupport(competitionFormDTO.getSupport());

            // 저장된 이미지 경로 설정 (이미지 파일 이름만 저장)
            if (savedImagePath != null) {
                competition.setImage(savedImagePath);
            }

            // 공모전 정보 저장
            competitionService.addCompetition(competition);

        } catch (IOException e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "파일 업로드에 실패했습니다.");
            return "competitions/addCompetition";
        }

        return "redirect:/competitions/main";  // 저장 후 메인 페이지로 리다이렉트
    }

    // 공모전 삭제
    @PostMapping("/delete/{id}")
    public String deleteCompetition(@PathVariable Long id) {
        competitionService.deleteCompetition(id);
        return "redirect:/competitions/main";  // 삭제 후 메인 페이지로 리다이렉트
    }

    // 공모전 수정 페이지
    @GetMapping("/edit/{id}")
    public String showEditCompetitionForm(@PathVariable Long id, Model model) {
        Competition competition = competitionService.getAllCompetitions().stream()
                .filter(comp -> comp.getId().equals(id))
                .findFirst().orElse(null);
        model.addAttribute("competition", competition);
        return "competitions/edit";  // 공모전 수정 페이지 템플릿
    }

    @PostMapping("/edit/{id}")
    public String editCompetition(@PathVariable Long id, @ModelAttribute Competition competition) {
        // 기존 공모전을 ID로 조회
        Competition existingCompetition = competitionService.getCompetitionById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition Id:" + id));

        // 필요한 필드 업데이트
        existingCompetition.setName(competition.getName());
        existingCompetition.setDescription(competition.getDescription());
        existingCompetition.setStartDate(competition.getStartDate());
        existingCompetition.setEndDate(competition.getEndDate());
        existingCompetition.setHost(competition.getHost());
        existingCompetition.setRequestStartDate(competition.getRequestStartDate());
        existingCompetition.setRequestEndDate(competition.getRequestEndDate());
        existingCompetition.setRequestPath(competition.getRequestPath());
        existingCompetition.setLocation(competition.getLocation());
        existingCompetition.setImage(competition.getImage());
        existingCompetition.setSupport(competition.getSupport());

        // Category와 CompetitionType 필드 업데이트
        existingCompetition.setCategory(competition.getCategory());  // Category 필드 업데이트
        existingCompetition.setCompetitionType(competition.getCompetitionType());  // CompetitionType 필드 업데이트

        // 공모전 업데이트
        competitionService.updateCompetition(existingCompetition);

        return "redirect:/competitions/main";  // 수정 후 메인 페이지로 리다이렉트
    }

    // 필터링된 공모전 목록을 JSON으로 반환
    @GetMapping("/filter")
    @ResponseBody
    public List<Competition> filterCompetitions(
            @RequestParam(name = "category", required = false) String categoryStr,
            @RequestParam(name = "competitionType", required = false) String competitionTypeStr,
            @RequestParam(name = "host", required = false) String host) {

        Category category = null;
        CompetitionType competitionType = null;

        // String에서 Category로 변환
        if (categoryStr != null && !categoryStr.isEmpty()) {
            try {
                category = Category.valueOf(categoryStr);
            } catch (IllegalArgumentException e) {
                throw new RuntimeException("Invalid category value: " + categoryStr);
            }
        }

        // String에서 CompetitionType으로 변환
        if (competitionTypeStr != null && !competitionTypeStr.isEmpty()) {
            try {
                competitionType = CompetitionType.valueOf(competitionTypeStr);
            } catch (IllegalArgumentException e) {
                throw new RuntimeException("Invalid competition type value: " + competitionTypeStr);
            }
        }

        return competitionService.filterCompetitions(category, competitionType, host);
    }

    @PostMapping("/like/{id}")
    public String likeCompetition(@PathVariable("id") Long competitionId, Principal principal) {
        String userEmail = principal.getName();  // 이메일로 수정
        competitionLikeService.likeCompetition(competitionId, userEmail);
        return "redirect:/competitions/details/" + competitionId;
    }

    @PostMapping("/unlike/{id}")
    public String unlikeCompetition(@PathVariable("id") Long competitionId, Principal principal) {
        String userEmail = principal.getName();  // 이메일로 수정
        competitionLikeService.unlikeCompetition(competitionId, userEmail);
        return "redirect:/competitions/details/" + competitionId;
    }
}

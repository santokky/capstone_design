package com.capstone.quicklendar.controller;

import com.capstone.quicklendar.domain.Competition;
import com.capstone.quicklendar.service.CompetitionService;
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
import java.util.List;

@Controller
@RequestMapping("/competitions")
public class CompetitionController {

    private static final Logger logger = LoggerFactory.getLogger(CompetitionController.class);

    private final CompetitionService competitionService;
    private final ImageHandler imageHandler;  // ImageHandler 주입

    @Autowired
    public CompetitionController(CompetitionService competitionService, ImageHandler imageHandler) {
        this.competitionService = competitionService;
        this.imageHandler = imageHandler;
    }

    @Value("${image.upload.dir}")
    private String uploadDir;

    // 공모전 메인 페이지 (공모전 목록 조회)
    @GetMapping("/main")
    public String getCompetitions(Model model) {
        List<Competition> competitions = competitionService.getAllCompetitions();
        model.addAttribute("competitions", competitions);
        return "competitions/main";  // 메인 페이지 템플릿
    }

    // 공모전 상세 페이지
    @GetMapping("/details/{id}")
    public String showCompetitionDetail(@PathVariable("id") Long id, Model model) {
        Competition competition = competitionService.getCompetitionById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition Id:" + id));
        model.addAttribute("competition", competition);
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

}

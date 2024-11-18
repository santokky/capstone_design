package com.capstone.quicklendar.service.competition;

import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import com.capstone.quicklendar.repository.competition.CompetitionRepository;
import com.capstone.quicklendar.util.ImageHandler;
import com.capstone.quicklendar.util.dto.CompetitionDTO;
import com.capstone.quicklendar.util.dto.CompetitionFormDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CompetitionService {

    private final CompetitionRepository competitionRepository;
    private final ImageHandler imageHandler;

    @Value("${image.base.url}") // 예: "http://localhost:8080/images/"
    private String imageBaseUrl;

    @Value("${image.upload.dir}") // 예: "/path/to/images/"
    private String uploadDir;

    @Autowired
    public CompetitionService(CompetitionRepository competitionRepository, ImageHandler imageHandler) {
        this.competitionRepository = competitionRepository;
        this.imageHandler = imageHandler;
    }

    public CompetitionDTO addCompetition(CompetitionFormDTO competitionFormDTO) throws IOException {
        // 이미지 저장
        String savedImagePath = imageHandler.saveImage(competitionFormDTO.getImage(), uploadDir);

        // Competition 엔티티 생성 및 저장
        Competition competition = new Competition();
        competition.setName(competitionFormDTO.getName());
        competition.setDescription(competitionFormDTO.getDescription());
        competition.setStartDate(competitionFormDTO.getStartDate());
        competition.setEndDate(competitionFormDTO.getEndDate());
        competition.setRequestStartDate(competitionFormDTO.getRequestStartDate());
        competition.setRequestEndDate(competitionFormDTO.getRequestEndDate());
        competition.setRequestPath(competitionFormDTO.getRequestPath());
        competition.setLocation(competitionFormDTO.getLocation());
        competition.setSupport(competitionFormDTO.getSupport());
        competition.setHost(competitionFormDTO.getHost());
        competition.setCategory(competitionFormDTO.getCategory());
        competition.setCompetitionType(competitionFormDTO.getCompetitionType());
        competition.setImage(savedImagePath); // 저장된 이미지 경로 설정

        competitionRepository.save(competition);

        return new CompetitionDTO(competition, imageBaseUrl);
    }

    // 공모전 전체 조회
    public List<CompetitionDTO> getAllCompetitions() {
        return competitionRepository.findAll().stream()
                .map(competition -> new CompetitionDTO(competition, imageBaseUrl))
                .collect(Collectors.toList());
    }

    // 공모전 상세 정보 가져오기
    public Optional<Competition> getCompetitionById(Long id) {
        return competitionRepository.findById(id);
    }

    // 카테고리, 타입, 주최자에 따른 필터링된 공모전 조회
    public List<Competition> filterCompetitions(Category category, CompetitionType competitionType, String host) {
        if (category != null && competitionType != null && host != null && !host.isEmpty()) {
            return competitionRepository.findByCategoryAndCompetitionTypeAndHost(category, competitionType, host);
        } else if (category != null && competitionType != null) {
            return competitionRepository.findByCategoryAndCompetitionType(category, competitionType);
        } else if (category != null) {
            return competitionRepository.findByCategory(category);
        } else if (competitionType != null) {
            return competitionRepository.findByCompetitionType(competitionType);
        } else if (host != null && !host.isEmpty()) {
            return competitionRepository.findByHost(host);
        } else {
            return competitionRepository.findAll();
        }
    }

    // 모든 공모전의 host 목록 조회 (중복 제거)
    public List<String> getAllHosts() {
        return competitionRepository.findDistinctHosts();
    }

    // 정렬된 공모전 목록 조회
    public List<Competition> getCompetitionsSortedByStartDate(boolean ascending) {
        return ascending ? competitionRepository.findAllByOrderByStartDateAsc() : competitionRepository.findAllByOrderByStartDateDesc();
    }

    public List<Competition> getCompetitionsSortedByEndDate(boolean ascending) {
        return ascending ? competitionRepository.findAllByOrderByEndDateAsc() : competitionRepository.findAllByOrderByEndDateDesc();
    }

    public List<Competition> getCompetitionsSortedByRequestStartDate(boolean ascending) {
        return ascending ? competitionRepository.findAllByOrderByRequestStartDateAsc() : competitionRepository.findAllByOrderByRequestStartDateDesc();
    }

    public List<Competition> getCompetitionsSortedByRequestEndDate(boolean ascending) {
        return ascending ? competitionRepository.findAllByOrderByRequestEndDateAsc() : competitionRepository.findAllByOrderByRequestEndDateDesc();
    }

    // 특정 기간 동안의 공모전 조회
    public List<Competition> getCompetitionsBetweenDates(LocalDate startDate, LocalDate endDate) {
        return competitionRepository.findCompetitionsBetweenDates(startDate, endDate);
    }

    // 정렬 조건에 따라 공모전 목록 반환
    public List<Competition> getCompetitionsSortedBy(String sortBy) {
        switch (sortBy) {
            case "likes":
                return competitionRepository.findAllByOrderByLikesDesc();
            case "createdAt":
                return competitionRepository.findAllByOrderByCreatedAtDesc();
            case "startDateAsc":
                return competitionRepository.findAllByOrderByStartDateAsc();
            case "startDateDesc":
                return competitionRepository.findAllByOrderByStartDateDesc();
            case "endDateAsc":
                return competitionRepository.findAllByOrderByEndDateAsc();
            case "endDateDesc":
                return competitionRepository.findAllByOrderByEndDateDesc();
            case "requestStartDateAsc":
                return competitionRepository.findAllByOrderByRequestStartDateAsc();
            case "requestStartDateDesc":
                return competitionRepository.findAllByOrderByRequestStartDateDesc();
            case "requestEndDateAsc":
                return competitionRepository.findAllByOrderByRequestEndDateAsc();
            case "requestEndDateDesc":
                return competitionRepository.findAllByOrderByRequestEndDateDesc();
            default:
                return competitionRepository.findAll();
        }
    }

    // 공모전 추가
    public Competition addCompetition(Competition competition) {
        return competitionRepository.save(competition);
    }

    // 공모전 삭제
    public void deleteCompetition(Long id) {
        competitionRepository.deleteById(id);
    }

    // 공모전 업데이트
    public void updateCompetition(Competition competition) {
        competitionRepository.save(competition);
    }

    // 좋아요 수로 내림차순 정렬된 공모전 목록 조회
    public List<Competition> getCompetitionsSortedByLikes() {
        return competitionRepository.findAll(Sort.by(Sort.Direction.DESC, "likes"));
    }

    // 등록일(createdAt)로 내림차순 정렬된 공모전 목록 조회
    public List<Competition> getCompetitionsSortedByCreatedAt() {
        return competitionRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    public Competition updateCompetition(Long id, CompetitionFormDTO competitionFormDTO, String imagePath) {
        // 기존 공모전 조회
        Competition existingCompetition = competitionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid competition ID: " + id));

        // CompetitionFormDTO의 필드 값으로 기존 Competition을 업데이트
        existingCompetition.setName(competitionFormDTO.getName());
        existingCompetition.setDescription(competitionFormDTO.getDescription());
        existingCompetition.setStartDate(competitionFormDTO.getStartDate());
        existingCompetition.setEndDate(competitionFormDTO.getEndDate());
        existingCompetition.setRequestStartDate(competitionFormDTO.getRequestStartDate());
        existingCompetition.setRequestEndDate(competitionFormDTO.getRequestEndDate());
        existingCompetition.setRequestPath(competitionFormDTO.getRequestPath());
        existingCompetition.setLocation(competitionFormDTO.getLocation());
        existingCompetition.setSupport(competitionFormDTO.getSupport());
        existingCompetition.setHost(competitionFormDTO.getHost());
        existingCompetition.setCategory(competitionFormDTO.getCategory());
        existingCompetition.setCompetitionType(competitionFormDTO.getCompetitionType());

        // 이미지 경로가 있을 경우 업데이트
        if (imagePath != null) {
            existingCompetition.setImage(imagePath);
        }

        // 업데이트된 Competition 저장
        return competitionRepository.save(existingCompetition);
    }
}

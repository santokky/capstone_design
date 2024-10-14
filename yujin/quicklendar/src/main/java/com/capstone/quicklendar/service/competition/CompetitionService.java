package com.capstone.quicklendar.service.competition;

import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import com.capstone.quicklendar.repository.competition.CompetitionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class CompetitionService {

    private final CompetitionRepository competitionRepository;

    @Autowired
    public CompetitionService(CompetitionRepository competitionRepository) {
        this.competitionRepository = competitionRepository;
    }

    // 공모전 전체 조회
    public List<Competition> getAllCompetitions() {
        return competitionRepository.findAll();
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
}

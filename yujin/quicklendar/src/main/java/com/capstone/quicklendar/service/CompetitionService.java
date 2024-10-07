package com.capstone.quicklendar.service;

import com.capstone.quicklendar.domain.Competition;
import com.capstone.quicklendar.domain.Category;
import com.capstone.quicklendar.domain.CompetitionType;
import com.capstone.quicklendar.repository.CompetitionRepository;
import org.springframework.beans.factory.annotation.Autowired;
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

    // 카테고리나 타입에 따른 공모전 조회
    public List<Competition> getCompetitionsByCategoryOrType(Category category, CompetitionType competitionType) {
        return competitionRepository.findByCategoryOrCompetitionType(category, competitionType);
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
}

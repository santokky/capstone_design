package com.capstone.quicklendar.repository;

import com.capstone.quicklendar.domain.Competition;
import com.capstone.quicklendar.domain.Category;
import com.capstone.quicklendar.domain.CompetitionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface CompetitionRepository extends JpaRepository<Competition, Long> {

    // Category 또는 CompetitionType으로 필터링하여 조회
    List<Competition> findByCategoryOrCompetitionType(Category category, CompetitionType competitionType);

    // 공모전 시작 날짜, 종료 날짜, 신청 시작 날짜, 신청 종료 날짜로 오름차순/내림차순 정렬
    List<Competition> findAllByOrderByStartDateAsc();
    List<Competition> findAllByOrderByStartDateDesc();
    List<Competition> findAllByOrderByEndDateAsc();
    List<Competition> findAllByOrderByEndDateDesc();
    List<Competition> findAllByOrderByRequestStartDateAsc();
    List<Competition> findAllByOrderByRequestStartDateDesc();
    List<Competition> findAllByOrderByRequestEndDateAsc();
    List<Competition> findAllByOrderByRequestEndDateDesc();

    // 특정 기간 내의 공모전 조회
    @Query("SELECT c FROM Competition c WHERE c.startDate >= :startDate AND c.endDate <= :endDate")
    List<Competition> findCompetitionsBetweenDates(LocalDate startDate, LocalDate endDate);
}

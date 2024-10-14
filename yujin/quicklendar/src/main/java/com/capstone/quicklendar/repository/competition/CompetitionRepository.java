package com.capstone.quicklendar.repository.competition;

import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface CompetitionRepository extends JpaRepository<Competition, Long> {

    @Query("SELECT DISTINCT c.host FROM Competition c")
    List<String> findDistinctHosts();

    // 카테고리와 타입, 주최자로 필터링
    List<Competition> findByCategoryAndCompetitionTypeAndHost(Category category, CompetitionType competitionType, String host);

    // 카테고리와 타입으로 필터링
    List<Competition> findByCategoryAndCompetitionType(Category category, CompetitionType competitionType);

    // 카테고리로 필터링
    List<Competition> findByCategory(Category category);

    // 공모전 타입으로 필터링
    List<Competition> findByCompetitionType(CompetitionType competitionType);

    // 주최자로 필터링
    List<Competition> findByHost(String host);

    // 공모전 시작 날짜, 종료 날짜, 신청 시작 날짜, 신청 종료 날짜로 오름차순/내림차순 정렬
    List<Competition> findAllByOrderByStartDateAsc();
    List<Competition> findAllByOrderByStartDateDesc();
    List<Competition> findAllByOrderByEndDateAsc();
    List<Competition> findAllByOrderByEndDateDesc();
    List<Competition> findAllByOrderByRequestStartDateAsc();
    List<Competition> findAllByOrderByRequestStartDateDesc();
    List<Competition> findAllByOrderByRequestEndDateAsc();
    List<Competition> findAllByOrderByRequestEndDateDesc();

    // 좋아요 수로 내림차순 정렬
    List<Competition> findAllByOrderByLikesDesc();

    // 등록 날짜로 내림차순(최신순) 정렬
    List<Competition> findAllByOrderByCreatedAtDesc();

    // 특정 기간 내의 공모전 조회
    @Query("SELECT c FROM Competition c WHERE c.startDate >= :startDate AND c.endDate <= :endDate")
    List<Competition> findCompetitionsBetweenDates(LocalDate startDate, LocalDate endDate);
}

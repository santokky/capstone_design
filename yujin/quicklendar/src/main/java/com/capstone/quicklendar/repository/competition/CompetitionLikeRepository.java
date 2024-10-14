package com.capstone.quicklendar.repository.competition;

import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.CompetitionLike;
import com.capstone.quicklendar.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompetitionLikeRepository extends JpaRepository<CompetitionLike, Long> {

    boolean existsByCompetitionAndUser(Competition competition, User user);

    void deleteByCompetitionAndUser(Competition competition, User user);

    boolean existsByUserAndCompetition(User user, Competition competition);

    // 유저와 공모전으로 좋아요 찾기
    Optional<CompetitionLike> findByUserAndCompetition(User user, Competition competition);
}

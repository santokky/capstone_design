package com.capstone.quicklendar.service.competition;

import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.CompetitionLike;
import com.capstone.quicklendar.domain.user.User;
import com.capstone.quicklendar.repository.competition.CompetitionLikeRepository;
import com.capstone.quicklendar.repository.competition.CompetitionRepository;
import com.capstone.quicklendar.repository.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class CompetitionLikeService {

    private final CompetitionLikeRepository competitionLikeRepository;
    private final CompetitionRepository competitionRepository;
    private final UserRepository userRepository;

    @Autowired
    public CompetitionLikeService(CompetitionLikeRepository competitionLikeRepository,
                                  CompetitionRepository competitionRepository,
                                  UserRepository userRepository) {
        this.competitionLikeRepository = competitionLikeRepository;
        this.competitionRepository = competitionRepository;
        this.userRepository = userRepository;
    }

    public void likeCompetition(Long competitionId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        Competition competition = competitionRepository.findById(competitionId)
                .orElseThrow(() -> new IllegalArgumentException("Competition not found"));

        // 이미 좋아요를 눌렀는지 확인
        if (!competitionLikeRepository.existsByUserAndCompetition(user, competition)) {
            CompetitionLike like = new CompetitionLike(user, competition);
            competitionLikeRepository.save(like);
        }
    }

    public void unlikeCompetition(Long competitionId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        Competition competition = competitionRepository.findById(competitionId)
                .orElseThrow(() -> new IllegalArgumentException("Competition not found"));

        CompetitionLike like = competitionLikeRepository.findByUserAndCompetition(user, competition)
                .orElseThrow(() -> new IllegalArgumentException("Like not found"));
        competitionLikeRepository.delete(like);
    }

    public boolean isLiked(Long competitionId, String userEmail) {
        Optional<User> user = userRepository.findByEmail(userEmail);
        Optional<Competition> competition = competitionRepository.findById(competitionId);

        if (user.isPresent() && competition.isPresent()) {
            return competitionLikeRepository.existsByUserAndCompetition(user.get(), competition.get());
        }
        return false;
    }
}

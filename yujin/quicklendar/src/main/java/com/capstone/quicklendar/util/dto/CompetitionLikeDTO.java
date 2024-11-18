package com.capstone.quicklendar.util.dto;

import com.capstone.quicklendar.domain.competition.CompetitionLike;

public class CompetitionLikeDTO {
    private Long competitionId;
    private Long userId;

    public CompetitionLikeDTO(CompetitionLike like) {
        this.competitionId = like.getCompetition().getId();
        this.userId = like.getUser().getId();
    }

    // Getters and Setters

    public Long getCompetitionId() {
        return competitionId;
    }

    public void setCompetitionId(Long competitionId) {
        this.competitionId = competitionId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
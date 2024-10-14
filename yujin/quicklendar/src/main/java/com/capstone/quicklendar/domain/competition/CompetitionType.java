package com.capstone.quicklendar.domain.competition;

public enum CompetitionType {
    COMPETITION("Competition"),
    ACTIVITY("Activity");

    private final String competitionTypeName;

    CompetitionType(String competitionTypeName) {
        this.competitionTypeName = competitionTypeName;
    }

    public String getCompetitionTypeName() {
        return competitionTypeName;
    }
}

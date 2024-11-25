package com.capstone.quicklendar.util.dto;

import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.Competition;
import com.capstone.quicklendar.domain.competition.CompetitionType;

import java.time.LocalDate;

public class CompetitionDTO {
    private Long id;
    private String name;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDate requestStartDate;
    private LocalDate requestEndDate;
    private String requestPath;
    private String location;
    private String imageUrl;
    private String support;
    private String host;
    private Category category;
    private CompetitionType competitionType;
    private int likeCount;

    public CompetitionDTO(Competition competition, String imageBaseUrl) {
        this.id = competition.getId();
        this.name = competition.getName();
        this.description = competition.getDescription();
        this.startDate = competition.getStartDate();
        this.endDate = competition.getEndDate();
        this.requestStartDate = competition.getRequestStartDate();
        this.requestEndDate = competition.getRequestEndDate();
        this.requestPath = competition.getRequestPath();
        this.location = competition.getLocation();
        this.imageUrl = imageBaseUrl + competition.getImage();
        this.support = competition.getSupport();
        this.host = competition.getHost();
        this.category = competition.getCategory();
        this.competitionType = competition.getCompetitionType();
        this.likeCount = competition.getLikeCount();
    }

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public LocalDate getRequestStartDate() {
        return requestStartDate;
    }

    public void setRequestStartDate(LocalDate requestStartDate) {
        this.requestStartDate = requestStartDate;
    }

    public LocalDate getRequestEndDate() {
        return requestEndDate;
    }

    public void setRequestEndDate(LocalDate requestEndDate) {
        this.requestEndDate = requestEndDate;
    }

    public String getRequestPath() {
        return requestPath;
    }

    public void setRequestPath(String requestPath) {
        this.requestPath = requestPath;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getSupport() {
        return support;
    }

    public void setSupport(String support) {
        this.support = support;
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public CompetitionType getCompetitionType() {
        return competitionType;
    }

    public void setCompetitionType(CompetitionType competitionType) {
        this.competitionType = competitionType;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
}

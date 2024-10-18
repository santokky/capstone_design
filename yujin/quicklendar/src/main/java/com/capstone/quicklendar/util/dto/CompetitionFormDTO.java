package com.capstone.quicklendar.util.dto;

import com.capstone.quicklendar.domain.competition.Category;
import com.capstone.quicklendar.domain.competition.CompetitionType;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;

public class CompetitionFormDTO {
    private String name;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDate requestStartDate;
    private LocalDate requestEndDate;
    private String requestPath;
    private String location;
    private MultipartFile image;  // MultipartFile을 여기에 받습니다.
    private String support;
    private String host;
    private Category category;
    private CompetitionType competitionType;

    // Getters and Setters

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

    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
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
}

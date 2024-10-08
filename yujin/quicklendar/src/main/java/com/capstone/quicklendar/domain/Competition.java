package com.capstone.quicklendar.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;

@Entity
@Table(name = "competitions")
@NoArgsConstructor
public class Competition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private LocalDate startDate;

    @Column(nullable = false)
    private LocalDate endDate;

    @Column(nullable = false)
    private LocalDate requestStartDate;

    @Column(nullable = false)
    private LocalDate requestEndDate;

    @Column(nullable = false)
    private String requestPath;

    @Column
    private String location;

    @Column
    private String image;

    @Column
    private String support;

    // 추가된 부분: 주최자 필드
    @Column(nullable = false)
    private String host;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;

    @Enumerated(EnumType.STRING)
    @Column(name = "competition_type", nullable = false)
    private CompetitionType competitionType;

    // Builder 패턴을 사용하여 인스턴스 생성
    @Builder
    public Competition(String name, String description, LocalDate startDate, LocalDate endDate, LocalDate requestStartDate,
                       LocalDate requestEndDate, String requestPath, String location, String image, String support,
                       Category category, CompetitionType competitionType, String host) {
        this.name = name;
        this.description = description;
        this.startDate = startDate;
        this.endDate = endDate;
        this.requestStartDate = requestStartDate;
        this.requestEndDate = requestEndDate;
        this.requestPath = requestPath;
        this.location = location;
        this.image = image;
        this.support = support;
        this.category = category;
        this.competitionType = competitionType;
        this.host = host;  // 주최자 추가
    }

    // Getter 및 Setter 메서드들 (Lombok 사용 안 함)
    public Long getId() {
        return id;
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

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;  // 이미지 경로를 문자열로 저장
    }

    public String getSupport() {
        return support;
    }

    public void setSupport(String support) {
        this.support = support;
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

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }
}


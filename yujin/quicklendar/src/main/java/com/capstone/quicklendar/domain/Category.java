package com.capstone.quicklendar.domain;

public enum Category {
    CREATIVE_ARTS_AND_DESIGN("Creative Arts and Design"),
    TECHNOLOGY_AND_ENGINEERING("Technology and Engineering"),
    BUSINESS_AND_ACADEMIC("Business and Academic");

    private final String categoryName;

    Category(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    @Override
    public String toString() {
        return this.name();  // Enum 이름을 반환하여 데이터베이스에 저장
    }
}

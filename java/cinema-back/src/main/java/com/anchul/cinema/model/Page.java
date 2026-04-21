package com.anchul.cinema.model;

import lombok.Data;

import java.util.List;

@Data
public class Page {
    private List<?> content;
    private int currentPage;
    private int endPage;
    private int startPage;
    private int maxPage;
}

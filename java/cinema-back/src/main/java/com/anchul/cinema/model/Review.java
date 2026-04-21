package com.anchul.cinema.model;

import lombok.Data;

import java.util.Date;

@Data
public class Review {
    private int id;
    private int movieId;
    private int userId;
    private String nickname;
    private String review;
    private Date entryDate;
    private String title;
}

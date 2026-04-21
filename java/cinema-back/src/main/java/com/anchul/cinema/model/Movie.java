package com.anchul.cinema.model;

import lombok.Data;

import java.util.Date;

@Data
public class Movie {
    private int id;
    private String title;
    private String director;
    private String content;
    private Date relaseDate;
    private String fileName;
    private String filePath;
    private String date;
}

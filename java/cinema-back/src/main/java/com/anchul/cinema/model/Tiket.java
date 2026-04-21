package com.anchul.cinema.model;

import java.util.List;

import lombok.Data;

@Data
public class Tiket {
	private int id;
    private String movieTitle;
    private int movieId;
    private String spotName;
    private String selectTime;
    private List<String> selectedSeats;
    private int roomsId;
    private int generalCount;
    private int teenagerCount;
    private int userId;
}

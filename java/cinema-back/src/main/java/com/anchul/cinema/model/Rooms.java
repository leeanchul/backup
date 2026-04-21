package com.anchul.cinema.model;

import java.util.List;

import lombok.Data;

@Data
public class Rooms {
	private int id; //pk
	private int cinemaId; //지점 
	private int movieId;  // 영화 번호 
	private String name; // 1관, 2관 등 
	private List<String> time; // 시간
}

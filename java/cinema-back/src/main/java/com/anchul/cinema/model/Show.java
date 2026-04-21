package com.anchul.cinema.model;

import java.util.List;

import lombok.Data;

@Data
public class Show {
	private int id;
	private int movieId;
	private int cinemaId;
	private int showTime;
	private String type;
	private String age;
	
	private String title;
	private String filePath;
}

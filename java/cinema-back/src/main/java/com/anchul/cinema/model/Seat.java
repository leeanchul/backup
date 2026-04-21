package com.anchul.cinema.model;

import lombok.Data;

@Data
public class Seat {
	private int id;
	private String[] rows;
	private String row;
	private int maxCol;
	private int roomsId;
	private String time;
	private boolean[][] isReserved;
}

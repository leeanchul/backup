package com.anchul.cinema.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.Rooms;
import com.anchul.cinema.model.Seat;
import com.anchul.cinema.service.RoomsService;
import com.anchul.cinema.service.SeatService;
import com.anchul.cinema.service.UserService;

@RestController
@RequestMapping("/api/rooms/")
public class RoomsController {

	private final JwtUtil JWT_UTIL;
    private final UserService USER_SERVICE;
    private final RoomsService ROOMS_SERVICE;
    private final SeatService SEAT_SERVICE;
    public RoomsController(JwtUtil jwtUtil, UserService userService, RoomsService roomsService,SeatService seatService) {
        JWT_UTIL = jwtUtil;
        USER_SERVICE = userService;
        ROOMS_SERVICE = roomsService;
        SEAT_SERVICE=seatService;
    }
    
    @GetMapping("roomsAll/{cinemaId}")
    public ResponseEntity<?> roomsAll(@PathVariable int cinemaId){
    	List<Rooms> result=ROOMS_SERVICE.roomsAll(cinemaId);
    	return ResponseEntity.ok(result);
    }
    
    // 상영 영화 정보 추가 
    @PostMapping("insert")
    public ResponseEntity<?> insert(@RequestBody Rooms rooms){
    	
    	// 여기서 rows. maxCol 지정해준다.
    	String[] rows = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};

    	Rooms result=ROOMS_SERVICE.insert(rooms);
    	
    	
    	for(int i=0; i<result.getTime().size();i++) {
        	Seat seat=new Seat();
        	
        	if(result.getName().equals("1관")) {
        		seat.setMaxCol(8);
        	}else if(result.getName().equals("2관")) {
        		seat.setMaxCol(9);
        	}else if(result.getName().equals("3관")) {
        		seat.setMaxCol(10);
        	}else {
        		seat.setMaxCol(4);
        	}
        	
        	seat.setRoomsId(result.getId());
        	seat.setRows(rows);
    		seat.setTime(result.getTime().get(i));
    		SEAT_SERVICE.insert(seat);
    	}
    	
    	return ResponseEntity.ok("test");
    }
}

package com.anchul.cinema.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.Seat;
import com.anchul.cinema.model.Tiket;
import com.anchul.cinema.model.User;
import com.anchul.cinema.service.SeatService;
import com.anchul.cinema.service.TiketService;
import com.anchul.cinema.service.UserService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/seat/")
public class SeatController {
	private final SeatService SEAT_SERVICE;
	private final TiketService TIKET_SERVICE;
	   private final JwtUtil JWT_UTIL;
	   private final UserService USER_SERVICE;
	public SeatController(SeatService seatService,TiketService tiketService,JwtUtil jwtUtil,UserService userService) {
		SEAT_SERVICE=seatService;
		TIKET_SERVICE=tiketService;
		JWT_UTIL=jwtUtil;
		USER_SERVICE=userService;
	}
	
	@PostMapping("insert")
	public ResponseEntity<?> insert(@RequestBody Seat seat){
		SEAT_SERVICE.insert(seat);
		
		return ResponseEntity.ok('t');
	}
	@GetMapping("seatOne/{id}/{time}")
	public ResponseEntity<?> seatOne(@PathVariable int id,@PathVariable String time){
		Seat result=SEAT_SERVICE.selectOne(id, time);
		System.out.println(result);
		//진행중
		return ResponseEntity.ok(result);
	}
	
	//결제 완료 시 seat update 해주고 , 예약 정보 추가.
	@PostMapping("tiket")
	public ResponseEntity<?> tiket(@RequestBody Tiket tiket,HttpServletRequest request) throws Exception{
    	String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
        tiket.setUserId(login.getId());
        // 여기서 만약 같은 영화, 같은 시간대 예약 정보가 있으면 예약 하지 못하게 해야한다.
        
        
		TIKET_SERVICE.insert(tiket);
		for (int i = 0; i < tiket.getSelectedSeats().size(); i++) {
		    String a = tiket.getSelectedSeats().get(i);

		    // 첫 번째 문자(영문 알파벳)를 숫자로 변환
		    String letter = a.substring(0, 1); // 알파벳 (예: A, B, C)
		    String number = a.substring(1);    // 숫자 (예: 5, 10, 15)

		    // 알파벳을 인덱스로 변환
		    int row = letter.charAt(0) - 'A';  // 'A'는 0, 'B'는 1, 'C'는 2 등으로 변환됨

		    // 숫자는 그대로 정수로 변환
		    int col = Integer.parseInt(number) - 1; // 1부터 시작하는 좌석 번호를 0-based로 처리하기 위해 -1

		    // 좌석 업데이트
		    SEAT_SERVICE.updateSeat(row, col, tiket.getRoomsId(), tiket.getSelectTime());
		}
			
		return ResponseEntity.ok("예약 완료!");
	}
	
	@PostMapping("tiketInfo")
	public ResponseEntity<?> tiketInfo(@RequestBody Tiket tiket){

		Tiket result= TIKET_SERVICE.getInfo(tiket);
		return ResponseEntity.ok(result);
	}

}

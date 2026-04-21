package com.anchul.cinema.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.Review;
import com.anchul.cinema.model.Show;
import com.anchul.cinema.model.User;
import com.anchul.cinema.service.ShowService;
import com.anchul.cinema.service.UserService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/show/")
public class ShowController {
	private final JwtUtil JWT_UTIL;
	private final UserService USER_SERVICE;
	private final ShowService SHOW_SERVICE;
	
	  public ShowController(JwtUtil jwtUtil, ShowService showService, UserService userService) {
	        JWT_UTIL = jwtUtil;
	        SHOW_SERVICE = showService;
	        USER_SERVICE = userService;
	    }
	  
	  @GetMapping("showAll/{id}")
	  public ResponseEntity<?> showAll(@PathVariable int id){
		  List<Show> result =SHOW_SERVICE.showAll(id);

		  return ResponseEntity.ok(result);
	  }
	  
	  @GetMapping("showAll")
	  public ResponseEntity<?> showAll(){
		  List<Show> result=SHOW_SERVICE.showAll();
		  return ResponseEntity.ok(result);
	  }
	  
	  
	  @PostMapping("insert")
	  public ResponseEntity<?> insert(@RequestBody Show show,HttpServletRequest request) throws Exception{
		  String authHeader = request.getHeader("Authorization");
	        if (authHeader == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
	        }
	        String username = JWT_UTIL.validateToken(authHeader);
	        if (username == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
	        }
	        User login = USER_SERVICE.findByUsername(username);
	        
	        if(login.getRole().equals("ROLE_MASTER")&&SHOW_SERVICE.validate(show)) {
	        	SHOW_SERVICE.insert(show);
	        	return ResponseEntity.ok("추가 되었습니다.");
	        }else if(login.getRole().equals("ROLE_MASTER") && !SHOW_SERVICE.validate(show)) {
	        	// 여기서 update 를 통해 시간추가 추후작업
	        	return ResponseEntity.ok("추가 되었습니다.");
	        }
	        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("관리자 전용 입니다.");
	  }
	  
	  @GetMapping("delete/{id}")
	  public ResponseEntity<?> delete(@PathVariable int id, HttpServletRequest request) throws Exception{
		  String authHeader = request.getHeader("Authorization");
	        if (authHeader == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
	        }
	        String username = JWT_UTIL.validateToken(authHeader);
	        if (username == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
	        }
	        User login = USER_SERVICE.findByUsername(username);
	        if(login.getRole().equals("ROLE_MASTER")){
	            SHOW_SERVICE.delete(id);
	            return ResponseEntity.ok("영화 삭제 완료");
	        }
		  
		  return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("관리자 전용 입니다.");
	  }
	  
	  @PostMapping("update")
	    public ResponseEntity<?> update(@RequestBody Show show , HttpServletRequest request) throws Exception {
	        String authHeader = request.getHeader("Authorization");
	        if (authHeader == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
	        }
	        String username = JWT_UTIL.validateToken(authHeader);
	        if (username == null) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
	        }
	        User login = USER_SERVICE.findByUsername(username);
	        if(login.getRole().equals("ROLE_MASTER")){
	            SHOW_SERVICE.showUpdate(show);
	            return ResponseEntity.ok("상영 영화 수정 완료");
	        }

	        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("리뷰 작성 실패");
	    }
	  
	  @GetMapping("showOne/{id}")
	  public ResponseEntity<?> showOne(@PathVariable int id){
	  Show result = SHOW_SERVICE.showOne(id);
	  return ResponseEntity.ok(result);
	  }
}

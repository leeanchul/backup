package com.anchul.cinema.controller;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.User;
import com.anchul.cinema.service.UserService;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

import org.springframework.http.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/user/")
public class UserController {
    private final JwtUtil JWT_UTIL;
    private final PasswordEncoder PASSWORD_ENCODER;
    private final UserService USER_SERVICE;
    public UserController(JwtUtil jwtUtil, PasswordEncoder passwordEncoder, UserService userService) {
        JWT_UTIL = jwtUtil;
        PASSWORD_ENCODER = passwordEncoder;
        USER_SERVICE = userService;
    }

  
    @PostMapping("register")
    public ResponseEntity<?> register(@RequestBody User user){
        user.setRole("ROLE_USER");
        user.setPassword(PASSWORD_ENCODER.encode(user.getPassword()));

        USER_SERVICE.register(user);
        return ResponseEntity.ok("회원가입 완료!");
    }

    @PostMapping("auth")
    public ResponseEntity<?> auth(@RequestBody User user){
        User origin=USER_SERVICE.findByUsername(user.getUsername());

        if (origin == null || !PASSWORD_ENCODER.matches(user.getPassword(), origin.getPassword())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("실패");
        }
        String token = JWT_UTIL.createToken(origin.getUsername());

       return ResponseEntity.ok(token);
    }
    
    @GetMapping("info")
    public ResponseEntity<?> info(HttpServletRequest request) throws Exception{
    	String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
    	login.setPassword("비밀입니다.");
    	return ResponseEntity.ok(login);
    }
    
    @PostMapping("update")
    public ResponseEntity<?> update(@RequestBody User user){
    	if(user.getNewNickname()==null) {
    		return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("null");
    	}
    	
    	if(USER_SERVICE.vaildateNickname(user.getNewNickname())) {
    		USER_SERVICE.updateNickname(user);
    		return ResponseEntity.ok("닉네임 변경완료");
    	}
    	
    	return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("이미 존재하는 닉네임");
    }
    
    
    @GetMapping("userAll")
    public ResponseEntity<?> userAll(){
    	List<User> result=USER_SERVICE.userAll();
    	
    	return ResponseEntity.ok(result);
    }
    
    @PostMapping("updatePwd")
    public ResponseEntity<?> updatePwd(@RequestBody User user,HttpServletRequest request) throws Exception{
    	System.out.println(user);
    	String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
    	
        // 평문과 암호문 비교할때는 matchers를 사용해야된다.
        if (PASSWORD_ENCODER.matches(user.getPassword(), login.getPassword())) {
        	user.setNewPassword(PASSWORD_ENCODER.encode(user.getNewPassword()));
        	USER_SERVICE.updatePwd(user);
        	return ResponseEntity.ok('t');
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("비밀번호가 일치하지 않습니다.");
    }
}

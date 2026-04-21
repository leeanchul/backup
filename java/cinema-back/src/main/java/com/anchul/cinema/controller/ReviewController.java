package com.anchul.cinema.controller;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.Review;
import com.anchul.cinema.model.User;
import com.anchul.cinema.service.ReviewService;
import com.anchul.cinema.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/review/")
public class ReviewController {
    private final JwtUtil JWT_UTIL;
    private final UserService USER_SERVICE;
    private final ReviewService REVIEW_SERVICE;

    public ReviewController(JwtUtil jwtUtil, UserService userService, ReviewService reviewService) {
        JWT_UTIL = jwtUtil;
        USER_SERVICE = userService;
        REVIEW_SERVICE = reviewService;
    }


    @GetMapping("reviewAll/{movieId}")
    public ResponseEntity<?> reviewAll(@PathVariable int movieId, HttpServletRequest request) throws Exception {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        List<Review> result = REVIEW_SERVICE.reviewAll(movieId);

        return ResponseEntity.ok(result);
    }

    @PostMapping("reviewInsert")
    public ResponseEntity<?> reviewInsert(@RequestBody Review review , HttpServletRequest request) throws Exception {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
        // 현재 로그인한 사용자 id 가져와서 설정해주기~
        review.setUserId(login.getId());
        review.setEntryDate(new Date());
        if(login.getRole().equals("ROLE_MASTER") && REVIEW_SERVICE.validate(review)){
            REVIEW_SERVICE.reviewInsert(review);
            return ResponseEntity.ok("리뷰 작성 완료");
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("리뷰 작성 실패");
    }

    @GetMapping("delete/{id}")
    public ResponseEntity<?> delete(@PathVariable int id, HttpServletRequest request) throws Exception {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
        Review review=REVIEW_SERVICE.reviewOne(id);
        if(login.getId()==review.getUserId()){
            REVIEW_SERVICE.deleteById(id);
            return ResponseEntity.ok("리뷰 삭제 완료");
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("본인이 작성한 글이 아닙니다.");
    }

    @PostMapping("update")
    public ResponseEntity<?> update(@RequestBody Review review , HttpServletRequest request) throws Exception {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);
        Review check=REVIEW_SERVICE.reviewOne(review.getId());
        if(login.getId()==check.getUserId()){
            REVIEW_SERVICE.reviewUpdate(review);
            return ResponseEntity.ok("리뷰 수정 완료");
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("리뷰 작성 실패");
    }
    
    @GetMapping("userReview/{userId}")
    public ResponseEntity<?> userReview(@PathVariable int userId,HttpServletRequest request) throws Exception{
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }
        User login = USER_SERVICE.findByUsername(username);

        if(!login.getRole().equals("ROLE_USER")) {
        	 List<Review> result= REVIEW_SERVICE.userReview(userId);
        	 return ResponseEntity.ok(result);
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("리뷰 작성 실패");
    }
}

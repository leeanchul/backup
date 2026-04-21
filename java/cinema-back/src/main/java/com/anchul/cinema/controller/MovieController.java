package com.anchul.cinema.controller;

import com.anchul.cinema.jwt.JwtUtil;
import com.anchul.cinema.model.Movie;
import com.anchul.cinema.model.Page;
import com.anchul.cinema.model.User;
import com.anchul.cinema.service.MovieService;
import com.anchul.cinema.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/movie/")
public class MovieController {
    private final JwtUtil JWT_UTIL;
    private final UserService USER_SERVICE;
    private final MovieService MOVIE_SERVICE;
    private final int PAGE_SIZE = 5;

    @Value("${upload.path}")
    private String path;

    public MovieController(JwtUtil jwtUtil, UserService userService, MovieService movieService) {
        JWT_UTIL = jwtUtil;
        USER_SERVICE = userService;
        MOVIE_SERVICE = movieService;
    }

    @GetMapping("movieAll")
    public ResponseEntity<?> movieAll() {
        List<Movie> list = MOVIE_SERVICE.movieAll();

        return ResponseEntity.ok(list);
    }

    @GetMapping("movieAll/{pageNo}")
    public ResponseEntity<?> movieAll(@PathVariable int pageNo){
        Pageable pageable = PageRequest.of(pageNo - 1, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id"));
        Slice<Movie> temp=MOVIE_SERVICE.findAllWithUser(pageable);
        Page page =new Page();
        page.setContent(temp.getContent());
        page.setCurrentPage(pageNo);

        int maxPage = (int) Math.ceil((double) MOVIE_SERVICE.countTotal() / PAGE_SIZE);

        page.setMaxPage(maxPage);
        int startPage = 1;
        int endPage = 5;
        if (maxPage < 5) {
            endPage = maxPage;
        } else if (pageNo > maxPage - 3) {
            startPage = maxPage - 4;
            endPage = maxPage;
        } else if (pageNo <= 3) {
            startPage = 1;
            endPage = 5;
        } else {
            startPage = pageNo - 2;
            endPage = pageNo + 2;
        }
        page.setStartPage(startPage);
        page.setEndPage(endPage);

        return ResponseEntity.ok(page);
    }

    @GetMapping("movieOne/{id}")
    public ResponseEntity<?> movieOne(@PathVariable int id) {
        Movie m = MOVIE_SERVICE.movieOne(id);
        return ResponseEntity.ok(m);
    }
    @PostMapping("flutterInsert")
    public ResponseEntity<?> flutterInsert(@RequestBody Movie movie){
    
    	Movie m = MOVIE_SERVICE.insert(movie);
    	return ResponseEntity.ok(m);
    }

    @PostMapping("insert")
    public ResponseEntity<?> insert(@ModelAttribute Movie movie,
                                    @RequestParam("file") MultipartFile f, HttpServletRequest request) throws Exception {

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }

        File dir = new File(path);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String ext = f.getOriginalFilename().substring(f.getOriginalFilename().lastIndexOf('.'));
        String uuid = UUID.randomUUID().toString();
        movie.setFileName(f.getOriginalFilename());
        movie.setFilePath(uuid + ext);
        // 서버 파일에 업로드
        File result = new File(path + uuid + ext);
        f.transferTo(result);

        // 날짜형식 변경
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date convertDate = dateFormat.parse(movie.getDate());
        movie.setRelaseDate(convertDate);

        User login = USER_SERVICE.findByUsername(username);

        if (login.getRole().equals("ROLE_MASTER")) {
            Movie m = MOVIE_SERVICE.insert(movie);
            return ResponseEntity.ok(m);
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("관리자 전용입니다.");
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

        if (login.getRole().equals("ROLE_MASTER")) {
            MOVIE_SERVICE.delete(id);
            return ResponseEntity.ok("삭제 되었습니다.");
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("관리자 전용입니다.");
    }

    @PostMapping("update")
    public ResponseEntity<?> update(@RequestBody Movie movie, HttpServletRequest request) throws Exception {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 없음");
        }
        String username = JWT_UTIL.validateToken(authHeader);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("로그인 정보가 존재 XX");
        }

        // 날짜형식 변경
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date convertDate = dateFormat.parse(movie.getDate());
        movie.setRelaseDate(convertDate);
        User login = USER_SERVICE.findByUsername(username);

        if (login.getRole().equals("ROLE_MASTER")) {
            MOVIE_SERVICE.update(movie);
            return ResponseEntity.ok("수정 성공!");
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("관리자 전용입니다.");
    }

    @ResponseBody
    @GetMapping(
            value = "/upload/{imageName}",
            // 이미지 type
            produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE, MediaType.IMAGE_GIF_VALUE}
    )
    public byte[] image(@PathVariable("imageName") String name) throws IOException {
    	
   
        if (name == null) {
            throw new IllegalArgumentException("Image name cannot be null");
        }
        // 읽어들일 파일의 절대 경로
        String absolutePath = path + File.separator + name;

        // 파일에서 읽어들일 InputStream
        try (InputStream is = new FileInputStream(absolutePath);
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

            // InputStream에서 ByteArrayOutputStream으로 읽어들임
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = is.read(buffer)) != -1) {
                baos.write(buffer, 0, bytesRead);
            }

            // 최종적으로 ByteArrayOutputStream 에서 byte[] 반환
            return baos.toByteArray();
        }
    }
}

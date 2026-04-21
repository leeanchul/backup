package com.anchul.cinema.jwt;

import com.anchul.cinema.model.User;
import com.anchul.cinema.repository.UserRepository;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtUtil JWTUTIL;
    private final UserRepository USER_REPOSITORY;

    public JwtAuthFilter(JwtUtil jwtutil, UserRepository userRepository) {
        JWTUTIL = jwtutil;
        USER_REPOSITORY = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String token=request.getHeader("Authorization");
        try{
            if(token != null && token.startsWith("Bearer")){
                token=token.substring(7);
                String username=JWTUTIL.validateToken(token);
                if(username != null){
                    User user = USER_REPOSITORY.findByUsername(username);
                    if(user != null){
                        UsernamePasswordAuthenticationToken authentication=
                                new UsernamePasswordAuthenticationToken(user,null,null);

                        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                        SecurityContextHolder.getContext().setAuthentication(authentication);
                    }
                   }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        filterChain.doFilter(request, response);
    }
}

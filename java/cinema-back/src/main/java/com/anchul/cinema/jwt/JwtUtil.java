package com.anchul.cinema.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {
    private final Key key;
    private final String SECRET_KEY="BITBoardBackEndSuperUltraStrongSecretKey";
    private final long EXP_TIME=86400000;
    public JwtUtil() {
        key= Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }

    public String createToken(String username){

        return Jwts.builder()
                .subject(username)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis()+EXP_TIME))
                .signWith(key)
                .compact();
    }

    public String validateToken(String token) throws Exception{
        if(token != null && token.startsWith("Bearer")){
            token=token.substring(7);
        }
        SecretKey key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
        Claims claims = Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return claims.getSubject();
    }

}

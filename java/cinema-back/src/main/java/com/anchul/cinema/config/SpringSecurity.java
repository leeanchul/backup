package com.anchul.cinema.config;

import com.anchul.cinema.jwt.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.FormLoginConfigurer;
import org.springframework.security.config.annotation.web.configurers.HttpBasicConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;

@Configuration
public class SpringSecurity {
    private final JwtAuthFilter JWT_FILTER;

    public SpringSecurity(JwtAuthFilter jwtFilter) {
        JWT_FILTER = jwtFilter;
    }
    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder(){
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity hs) throws Exception{
        hs
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors->cors.configurationSource(req->{
                    CorsConfiguration config=new CorsConfiguration();
                   // config.addAllowedOrigin("http://localhost:3000");
                   // config.addAllowedOrigin("http://localhost:3001");
                    config.addAllowedOrigin("*");
                    config.addAllowedMethod("*");
                    config.addAllowedHeader("*");

                    return config;
                }))
                .authorizeHttpRequests(req->
                        req
                                .requestMatchers("/api/user/**").permitAll()
                                .anyRequest().authenticated()
                )
                .httpBasic(HttpBasicConfigurer::disable)
                .sessionManagement(session->
                        session
                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                ).formLogin(FormLoginConfigurer::disable)
                .addFilterBefore(JWT_FILTER, UsernamePasswordAuthenticationFilter.class);

        return hs.build();
    }
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception{
        return config.getAuthenticationManager();
    }
}

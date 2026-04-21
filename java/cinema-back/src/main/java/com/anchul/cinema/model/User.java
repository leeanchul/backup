package com.anchul.cinema.model;


import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Document(collection = "user")
public class User {
    @Id
    private int id;
    private String username;
    private String password;
    private String nickname;
    private String role;
    
    private String newNickname;
    private String newPassword;
}

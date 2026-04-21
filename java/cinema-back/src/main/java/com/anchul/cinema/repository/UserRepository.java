package com.anchul.cinema.repository;

import com.anchul.cinema.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UserRepository extends MongoRepository<User,Object> {
    User findByUsername(String username);
}

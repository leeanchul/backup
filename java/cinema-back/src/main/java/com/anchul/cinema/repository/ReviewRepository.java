package com.anchul.cinema.repository;

import com.anchul.cinema.model.Review;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ReviewRepository extends MongoRepository<Review,Object> {

    void deleteById(int id);
}

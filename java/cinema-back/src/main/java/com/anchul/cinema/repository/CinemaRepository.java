package com.anchul.cinema.repository;

import com.anchul.cinema.model.Cinema;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

public interface CinemaRepository extends MongoRepository<Cinema,Object> {
    @Query("{}")
    Slice<Cinema> findAllWithUser(Pageable pagebale);

    void deleteById(int id);
}

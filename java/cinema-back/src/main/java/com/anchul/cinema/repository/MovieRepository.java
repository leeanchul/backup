package com.anchul.cinema.repository;

import com.anchul.cinema.model.Movie;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

public interface MovieRepository extends MongoRepository<Movie,Object> {
    void deleteById(int id);

    @Query("{}")
    Slice<Movie> findAllWithUser(Pageable pagebale);
}

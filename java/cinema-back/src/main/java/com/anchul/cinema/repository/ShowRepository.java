package com.anchul.cinema.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import com.anchul.cinema.model.Movie;
import com.anchul.cinema.model.Show;

public interface ShowRepository extends MongoRepository<Show, Object>{
	void deleteById(int id);
}

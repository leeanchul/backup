package com.anchul.cinema.repository;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.anchul.cinema.model.Rooms;

public interface RoomsRepository extends MongoRepository<Rooms, Integer>{

}

package com.anchul.cinema.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import com.anchul.cinema.model.Seat;

public interface SeatRepository extends  MongoRepository<Seat,Object> {

}

package com.anchul.cinema.repository;

import com.anchul.cinema.model.Sequence;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface SequenceRepository extends MongoRepository<Sequence,String> {
}

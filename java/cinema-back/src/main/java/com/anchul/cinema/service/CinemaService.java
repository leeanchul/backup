package com.anchul.cinema.service;

import com.anchul.cinema.model.Cinema;
import com.anchul.cinema.model.Movie;
import com.anchul.cinema.repository.CinemaRepository;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.match;

import java.util.ArrayList;
import java.util.List;

@Service
public class CinemaService {
    private final CinemaRepository CINEMA_REPOSITORY;
    private final SequenceService SEQ_SERVICE;
    private final MongoTemplate MONGO_TEMPLATE;
    private final String TYPE="cinema";

    public CinemaService(CinemaRepository cinemaRepository, SequenceService seqService, MongoTemplate mongoTemplate) {
        CINEMA_REPOSITORY = cinemaRepository;
        SEQ_SERVICE = seqService;
        MONGO_TEMPLATE = mongoTemplate;
    }

    // 조회ㅣ
    public List<Cinema> cinemaAll(){
        return CINEMA_REPOSITORY.findAll();
    }

    // page 조회
    public Slice<Cinema> findAllWithUser(Pageable pageable){

        return CINEMA_REPOSITORY.findAllWithUser(pageable);
    }
    
    // 지역 조회
    public List<Cinema> findAllWithUser(String area){
    	Query query=new Query(Criteria.where("area").is(area));
        return MONGO_TEMPLATE.find(query, Cinema.class);
    }

    // 입력
    public void cinemaInsert(Cinema cinema){
        cinema.setId(SEQ_SERVICE.getSequence(TYPE));
        CINEMA_REPOSITORY.save(cinema);
    }

    // 페이지 총 수
    public long countTotal(){
        return MONGO_TEMPLATE.count(new Query(),Cinema.class);
    }

    // 삭제
    public void deleteById(int id) {
        CINEMA_REPOSITORY.deleteById(id);
    }
    
    // update
    public void updateById(Cinema cinema) {
    	Query query=new Query(Criteria.where("_id").is(cinema.getId()));
    	Update update=new Update()
    			.set("area", cinema.getArea())
    			.set("spotName", cinema.getSpotName());
    	MONGO_TEMPLATE.findAndModify(query, update, Cinema.class);
    }
    
    
}

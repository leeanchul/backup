package com.anchul.cinema.service;

import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import com.anchul.cinema.model.Seat;
import com.anchul.cinema.model.Tiket;
import com.anchul.cinema.repository.TiketRepository;

@Service
public class  TiketService {
	 private final SequenceService SEQ_SERVICE;
	 private final MongoTemplate MONGO_TEMPLATE;
	 private final TiketRepository TIKET_REPOSITORY;
	 private final String TYPE="tiket";
    public TiketService(SequenceService sequenceService, MongoTemplate mongoTemplate, TiketRepository tiketRepository) {
    	SEQ_SERVICE = sequenceService;
    	MONGO_TEMPLATE = mongoTemplate;
    	TIKET_REPOSITORY = tiketRepository;
    }
    
    
    // 티켓 추가
    public void insert(Tiket tiket) {
        // ID 설정 (SequenceService로부터 가져옴)
        tiket.setId(SEQ_SERVICE.getSequence(TYPE));

        // tiket 객체를 MongoDB에 삽입
        TIKET_REPOSITORY.save(tiket);
    }

    // 티켓 info
    public Tiket getInfo(Tiket tiket) {
        Query query = new Query(Criteria.where("userId").is(tiket.getUserId())); // "time"을 문자열로 수정
        return MONGO_TEMPLATE.findOne(query, Tiket.class);
    }
    
}

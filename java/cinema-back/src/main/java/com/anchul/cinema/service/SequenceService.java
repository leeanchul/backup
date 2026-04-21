package com.anchul.cinema.service;

import com.anchul.cinema.model.Sequence;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.MongoOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;


@Service
public class SequenceService {
    private final MongoTemplate MONGO_TEMPLATE;

    public SequenceService(MongoTemplate mongoTemplate) {
        MONGO_TEMPLATE = mongoTemplate;
    }

    public int getSequence(String type){
        // DB 문서 찾는 Query 객체 생성, Criteria 클래스 값이 일치하는 문서 찾도록 지정
        Query query=new Query(Criteria.where("_id").is(type));
        // seq 필드 값을 1 증가시키키 위한 Update 객체 생성
        Update update=new Update().inc("seq",1);
        // returnNew :true 이면 값이 바뀐 후의 새로운 값을 return, false 이면 update 전 저장된 값을 return
        FindAndModifyOptions options=FindAndModifyOptions.options().returnNew(false).upsert(true);
        //
        Sequence sequence = MONGO_TEMPLATE.findAndModify(query,update,options, Sequence.class);

        return sequence.getSeq();
    }
}

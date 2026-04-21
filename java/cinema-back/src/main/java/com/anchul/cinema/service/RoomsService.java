package com.anchul.cinema.service;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.match;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import com.anchul.cinema.model.Rooms;
import com.anchul.cinema.model.Scope;
import com.anchul.cinema.repository.RoomsRepository;
import com.mongodb.client.result.DeleteResult;

@Service
public class RoomsService {
	private final RoomsRepository ROOMS_REPOSITORY;
	private final MongoTemplate MONGO_TEMPLATE;
	  private final SequenceService SEQ_SERVICE;
	private final String TYPE="rooms";
	
	   public RoomsService(RoomsRepository RoomsRepository, MongoTemplate mongoTemplate,SequenceService sequenceService) {
		   ROOMS_REPOSITORY= RoomsRepository;
		   MONGO_TEMPLATE = mongoTemplate;
		   SEQ_SERVICE=sequenceService;
	    }
	 
	   public List<Rooms> roomsAll(int cinemaId){
		     // 집계연산 목록
	        List<AggregationOperation> operations = new ArrayList<>();
	        // 매치 연산(where)
	        operations.add(match(Criteria.where("cinemaId").is(cinemaId)));
	        // 집계연산 목록을 하나의 집계목록으로 만들기
	        Aggregation aggregation = Aggregation.newAggregation(operations);
	        
	        AggregationResults<Rooms> results = MONGO_TEMPLATE.aggregate(aggregation, "rooms", Rooms.class);
	        return results.getMappedResults();
		  
	   }
	   
	   public Rooms insert(Rooms rooms) {
		   rooms.setId(SEQ_SERVICE.getSequence(TYPE));
		 return  ROOMS_REPOSITORY.save(rooms);
	   }
	   public void ParentDelete(int cinemaId) {
		    Query query = new Query(Criteria.where("cinemaId").is(cinemaId));

		  MONGO_TEMPLATE.remove(query, Rooms.class);
		   
		}


}

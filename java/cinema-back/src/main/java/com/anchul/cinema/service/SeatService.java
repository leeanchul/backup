package com.anchul.cinema.service;


import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.BooleanOperators.And;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import com.anchul.cinema.model.Movie;
import com.anchul.cinema.model.Seat;
import com.anchul.cinema.model.Show;
import com.anchul.cinema.repository.SeatRepository;

@Service
public class SeatService {
	private final SeatRepository SEAT_REPOSITORY;
	 private final SequenceService SEQ_SERVICE;
	 private final MongoTemplate MONGO_TEMPLATE;
	 private final String TYPE="seat";
	    public SeatService(SeatRepository seatRepository, SequenceService sequenceService, MongoTemplate mongoTemplate) {
	        this.SEAT_REPOSITORY = seatRepository;
	        this.SEQ_SERVICE = sequenceService;
	        this.MONGO_TEMPLATE = mongoTemplate;
	    }
	    
	    // 상영관 추가
	    public void insert(Seat seat) {
	        boolean[][] test = new boolean[seat.getRows().length][seat.getMaxCol()];

	        for (int row = 0; row < seat.getRows().length; row++) {
	            for (int col = 0; col < seat.getMaxCol(); col++) {
	                test[row][col] = false;
	            }
	        }

	        seat.setId(SEQ_SERVICE.getSequence(TYPE));
	        seat.setIsReserved(test);
	        SEAT_REPOSITORY.save(seat);
	    }
	    
	    // 사영관 조회
	    public Seat selectOne(int id, String time) {
	        Query query = new Query(Criteria.where("roomsId").is(id)
	                .and("time").is(time)); // "time"을 문자열로 수정
	        return MONGO_TEMPLATE.findOne(query, Seat.class);
	    }
	    
	    // 상영관 좌석 예약
	    public void updateSeat(int row, int col, int roomsId, String time) {
	        // 쿼리 설정: roomsId와 time을 기반으로 검색
	        Query query = new Query(Criteria.where("roomsId").is(roomsId)
	                .and("time").is(time));

	        // 배열 경로 설정: isReserved[row][col] 위치
	        String arrayPath = String.format("isReserved.%d.%d", row, col);

	        // 업데이트 설정: 해당 위치에 true 설정
	        Update update = new Update().set(arrayPath, true);
	        
	        // MongoDB 업데이트 실행
	       MONGO_TEMPLATE.findAndModify(query, update, Seat.class);
	 
	    }



		// 부모에서삭제
		   public void ParentDelete(int cinemaId) {
			    Query query = new Query(Criteria.where("roomsId").is(cinemaId));

			  MONGO_TEMPLATE.remove(query, Seat.class);
			   
			}
}

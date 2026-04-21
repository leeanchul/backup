package com.anchul.cinema.service;

import com.anchul.cinema.model.Movie;
import com.anchul.cinema.model.Review;
import com.anchul.cinema.model.Scope;
import com.anchul.cinema.repository.ReviewRepository;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.*;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.project;

@Service
public class ReviewService {
    private final ReviewRepository REVIEW_REPOSITORY;
    private final SequenceService SEQ_SERVICE;
    private final String TYPE="review";
    private final MongoTemplate MONGO_TEMPLATE;

    public ReviewService(ReviewRepository reviewRepository, SequenceService seqService, MongoTemplate mongoTemplate) {
        REVIEW_REPOSITORY = reviewRepository;
        SEQ_SERVICE = seqService;
        MONGO_TEMPLATE = mongoTemplate;
    }

    // user의 모든 리뷰
    public List<Review> userReview(int userId){
    	 List<AggregationOperation> operations = new ArrayList<>();
    	 operations.add(match(Criteria.where("userId").is(userId)));
    	 operations.add(lookup("user", "userId", "_id", "writer"));
    	 operations.add(lookup("movie", "movieId", "_id", "movie"));
         // 배열로 분해하기
         operations.add(unwind("writer"));
         operations.add(unwind("movie"));
         // prject 연산
         operations.add(project("id", "movieId", "review", "entryDate")
                 .and("writer.nickname").as("nickname").and("movie.title").as("title"));
         Aggregation aggregation = Aggregation.newAggregation(operations);
         AggregationResults<Review> results = MONGO_TEMPLATE.aggregate(aggregation, "review", Review.class);

         return results.getMappedResults();
    }
    
    // 각 영화의 리뷰들
    public List<Review> reviewAll(int movieId) {
        List<AggregationOperation> operations = new ArrayList<>();
        operations.add(match(Criteria.where("movieId").is(movieId)));
        //조인 연산 (lookup) (join) 절) : 조인할 대상 , 조인할때 사용할 필드, 조인할대상에 필드, 조인 저장할 필드
        operations.add(lookup("user", "userId", "_id", "writer"));
        // 배열로 분해하기
        operations.add(unwind("writer"));
        // prject 연산
        operations.add(project("id", "movieId", "review", "entryDate")
                .and("writer.nickname").as("nickname"));
        Aggregation aggregation = Aggregation.newAggregation(operations);
        AggregationResults<Review> results = MONGO_TEMPLATE.aggregate(aggregation, "review", Review.class);

        return results.getMappedResults();
    }

    public void deleteById(int id) {
        REVIEW_REPOSITORY.deleteById(id);
    }

    public boolean validate(Review review) {
        // 집계연산 목록
        List<AggregationOperation> operations = new ArrayList<>();
        // 매치 연산(where)
        operations.add(match(Criteria.where("userId").is(review.getUserId())
                .and("movieId").is(review.getMovieId())));

        // 집계연산 목록을 하나의 집계목록으로 만들기
        Aggregation aggregation = Aggregation.newAggregation(operations);

        // 집계 객체에 = (집계파이프라인, 테이블명, 매핑값)
        AggregationResults<Review> results = MONGO_TEMPLATE.aggregate(aggregation, "review", Review.class);
        return results.getUniqueMappedResult()==null;
    }

    public Review reviewOne(int id){
        Query query=new Query(Criteria.where("_id").is(id));
        return MONGO_TEMPLATE.findOne(query, Review.class);
    }

    public void reviewInsert(Review review) {
        review.setId(SEQ_SERVICE.getSequence(TYPE));
        REVIEW_REPOSITORY.save(review);
    }

    public void reviewUpdate(Review review){
        Query query = new Query(Criteria.where("_id").is(review.getId()));
        Update update = new Update()
                .set("review",review.getReview());
        MONGO_TEMPLATE.findAndModify(query, update, Review.class);
    }
}

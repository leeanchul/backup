package com.anchul.cinema.repository;

import com.anchul.cinema.model.Scope;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface ScopeRepository extends MongoRepository<Scope,Object> {
    // mongo DB 에서 쿼리 movieId : ?0 파라미터값 이라는 뜻
   // @Query("{'movieId':?0}") 근데 이렇게 하면 user 에 nickname 을 얻어오지 못한다.ㅜㅜ
    //    List<Scope> findAllWithUser(int movieId);

    void deleteById(int id);
}

package com.anchul.cinema.service;

import com.anchul.cinema.model.Movie;
import com.anchul.cinema.repository.MovieRepository;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MovieService {
    private final MovieRepository MOVIE_REPOSITORY;
    private final SequenceService SEQ_SERVICE;
    private final String TYPE = "movie";
    private final MongoTemplate MONGO_TEMPLATE;

    public MovieService(MovieRepository movieRepository, SequenceService seqService, MongoTemplate mongoTemplate1) {
        MOVIE_REPOSITORY = movieRepository;
        SEQ_SERVICE = seqService;
        MONGO_TEMPLATE = mongoTemplate1;

    }

    public Movie insert(Movie movie) {
        movie.setId(SEQ_SERVICE.getSequence(TYPE));
        return MOVIE_REPOSITORY.save(movie);
    }

    public void delete(int id) {
        MOVIE_REPOSITORY.deleteById(id);
    }

    public void update(Movie movie) {
        Query query = new Query(Criteria.where("_id").is(movie.getId()));
        Update update = new Update()
                .set("title", movie.getTitle())
                .set("content", movie.getContent())
                .set("director", movie.getDirector())
                .set("relaseDate", movie.getRelaseDate());
        MONGO_TEMPLATE.findAndModify(query, update, Movie.class);
    }

    public List<Movie> movieAll() {
        return MOVIE_REPOSITORY.findAll();
    }

    public Movie movieOne(int id) {
        Query query = new Query(Criteria.where("_id").is(id));
        return MONGO_TEMPLATE.findOne(query, Movie.class);
    }

    public Slice<Movie> findAllWithUser(Pageable pageable){

        return MOVIE_REPOSITORY.findAllWithUser(pageable);
    }

    public long countTotal(){
        return MONGO_TEMPLATE.count(new Query(),Movie.class);
    }
}

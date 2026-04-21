package com.anchul.cinema.service;

import static org.springframework.data.mongodb.core.aggregation.Aggregation.lookup;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.match;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.project;
import static org.springframework.data.mongodb.core.aggregation.Aggregation.unwind;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.CriteriaDefinition;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import com.anchul.cinema.model.Movie;
import com.anchul.cinema.model.Review;
import com.anchul.cinema.model.Rooms;
import com.anchul.cinema.model.Show;
import com.anchul.cinema.repository.CinemaRepository;
import com.anchul.cinema.repository.ShowRepository;

@Service
public class ShowService {
    private final ShowRepository SHOW_REPOSITORY;
    private final SequenceService SEQ_SERVICE;
    private final MongoTemplate MONGO_TEMPLATE;
    private final String TYPE="show";

    public ShowService(ShowRepository showRepository, SequenceService seqService, MongoTemplate mongoTemplate) {
    	SHOW_REPOSITORY = showRepository;
        SEQ_SERVICE = seqService;
        MONGO_TEMPLATE = mongoTemplate;
    }
    
    public List<Show> showAll(){
    	List<AggregationOperation> operations = new ArrayList<>();
    	 operations.add(lookup("movie", "movieId", "_id", "movieInfo"));
    	 operations.add(unwind("movieInfo"));
    	 operations.add(project("id", "movieId", "showTime", "type","age","cinemaId")
                 .and("movieInfo.title").as("title").and("movieInfo.filePath").as("filePath"));
    	 Aggregation aggregation = Aggregation.newAggregation(operations);
    	 AggregationResults<Show> results = MONGO_TEMPLATE.aggregate(aggregation, "show", Show.class);

         return results.getMappedResults();
    }
    
    public List<Show> showAll(int id) {
    	List<AggregationOperation> operations = new ArrayList<>();
    	 operations.add(match(Criteria.where("cinemaId").is(id)));
    	 operations.add(lookup("movie", "movieId", "_id", "movieInfo"));
    	 operations.add(unwind("movieInfo"));
    	 operations.add(project("id", "movieId", "showTime", "type","age","cinemaId")
                 .and("movieInfo.title").as("title").and("movieInfo.filePath").as("filePath"));
    	 Aggregation aggregation = Aggregation.newAggregation(operations);
    	 AggregationResults<Show> results = MONGO_TEMPLATE.aggregate(aggregation, "show", Show.class);

         return results.getMappedResults();
    }
    
	public void insert(Show show) {
		show.setId(SEQ_SERVICE.getSequence(TYPE));
		SHOW_REPOSITORY.save(show);
	}
	
	
	public boolean validate(Show show) {
		 Query query = new Query(Criteria.where("movieId").is(show.getMovieId()).and("cinemaId").is(show.getCinemaId()));
	     return MONGO_TEMPLATE.findOne(query, Show.class)==null;
	}
	
	public void delete(int id) {
		SHOW_REPOSITORY.deleteById(id);
	}
	
	   public void ParentDelete(int cinemaId) {
		    Query query = new Query(Criteria.where("cinemaId").is(cinemaId));

		  MONGO_TEMPLATE.remove(query, Show.class);
		   
		}
	 public void showUpdate(Show show){
	        Query query = new Query(Criteria.where("_id").is(show.getId()));
	        Update update = new Update()
	                .set("movieId",show.getMovieId())
	                .set("showTime",show.getShowTime())
	                .set("type",show.getType())
	                .set("age",show.getAge());
	        MONGO_TEMPLATE.findAndModify(query, update, Show.class);
	    }
	 public Show showOne(int id){
		 Query query = new Query(Criteria.where("_id").is(id));
		 return MONGO_TEMPLATE.findOne(query,Show.class);
	 }
}

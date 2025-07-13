package com.restaurant.orderservice.repository;

import com.restaurant.orderservice.model.Order;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends MongoRepository<Order, String> {
    List<Order> findByRestaurantId(String restaurantId);
    List<Order> findByCustomerId(String customerId);
    List<Order> findByStatus(String status);
    List<Order> findByRestaurantIdAndStatus(String restaurantId, String status);
    List<Order> findByCustomerIdAndStatus(String customerId, String status);
    
    @Query("{'restaurantId': ?0, 'orderTime': {$gte: ?1, $lte: ?2}}")
    List<Order> findByRestaurantIdAndOrderTimeBetween(
        String restaurantId, LocalDateTime startTime, LocalDateTime endTime);
    
    @Query("{'customerId': ?0, 'orderTime': {$gte: ?1, $lte: ?2}}")
    List<Order> findByCustomerIdAndOrderTimeBetween(
        String customerId, LocalDateTime startTime, LocalDateTime endTime);
    
    @Query("{'status': ?0, 'orderTime': {$lte: ?1}}")
    List<Order> findByStatusAndOrderTimeBefore(String status, LocalDateTime time);
    
    @Query(value = "{'restaurantId': ?0}", count = true)
    long countByRestaurantId(String restaurantId);
    
    @Query(value = "{'customerId': ?0}", count = true)
    long countByCustomerId(String customerId);
} 
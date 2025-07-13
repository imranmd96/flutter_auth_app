package com.restaurant.orderservice.model;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Document(collection = "orders")
public class Order {
    @Id
    private String id;
    private String restaurantId;
    private String customerId;
    private List<OrderItem> items;
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal deliveryFee;
    private BigDecimal total;
    private String status;
    private String paymentStatus;
    private String paymentId;
    private LocalDateTime orderTime;
    private LocalDateTime estimatedDeliveryTime;
    private LocalDateTime actualDeliveryTime;
    private String deliveryAddress;
    private String specialInstructions;
    private String couponCode;
    private BigDecimal discount;
    private String deliveryDriverId;
    private String deliveryStatus;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 
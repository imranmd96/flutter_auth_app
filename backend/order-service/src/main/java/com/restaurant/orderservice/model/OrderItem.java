package com.restaurant.orderservice.model;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderItem {
    private String menuItemId;
    private String name;
    private String description;
    private BigDecimal price;
    private Integer quantity;
    private List<String> customizationOptions;
    private String specialInstructions;
    private BigDecimal subtotal;
} 
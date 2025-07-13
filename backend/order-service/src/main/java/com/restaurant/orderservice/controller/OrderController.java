package com.restaurant.orderservice.controller;

import com.restaurant.orderservice.model.Order;
import com.restaurant.orderservice.service.OrderService;
import com.restaurant.orderservice.exception.OrderException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    @Autowired
    private OrderService orderService;

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody Order order) {
        try {
            Order createdOrder = orderService.createOrder(order);
            return ResponseEntity.ok(createdOrder);
        } catch (OrderException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrder(@PathVariable String orderId) {
        try {
            Order order = orderService.getOrder(orderId);
            return ResponseEntity.ok(order);
        } catch (OrderException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<List<Order>> getRestaurantOrders(@PathVariable String restaurantId) {
        List<Order> orders = orderService.getRestaurantOrders(restaurantId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Order>> getCustomerOrders(@PathVariable String customerId) {
        List<Order> orders = orderService.getCustomerOrders(customerId);
        return ResponseEntity.ok(orders);
    }

    @PatchMapping("/{orderId}/status")
    public ResponseEntity<Order> updateOrderStatus(
        @PathVariable String orderId,
        @RequestParam String status
    ) {
        try {
            Order updatedOrder = orderService.updateOrderStatus(orderId, status);
            return ResponseEntity.ok(updatedOrder);
        } catch (OrderException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{orderId}/payment")
    public ResponseEntity<Order> updatePaymentStatus(
        @PathVariable String orderId,
        @RequestParam String paymentStatus,
        @RequestParam String paymentId
    ) {
        try {
            Order updatedOrder = orderService.updatePaymentStatus(orderId, paymentStatus, paymentId);
            return ResponseEntity.ok(updatedOrder);
        } catch (OrderException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{orderId}/delivery")
    public ResponseEntity<Order> updateDeliveryStatus(
        @PathVariable String orderId,
        @RequestParam String deliveryStatus,
        @RequestParam String deliveryDriverId
    ) {
        try {
            Order updatedOrder = orderService.updateDeliveryStatus(
                orderId, deliveryStatus, deliveryDriverId);
            return ResponseEntity.ok(updatedOrder);
        } catch (OrderException e) {
            return ResponseEntity.notFound().build();
        }
    }
} 
package com.restaurant.orderservice.service;

import com.restaurant.orderservice.model.Order;
import com.restaurant.orderservice.model.OrderItem;
import com.restaurant.orderservice.repository.OrderRepository;
import com.restaurant.orderservice.exception.OrderException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
    @Autowired
    private OrderRepository orderRepository;
    
    @Value("${order.max-items-per-order}")
    private int maxItemsPerOrder;
    
    @Value("${order.max-orders-per-customer}")
    private int maxOrdersPerCustomer;
    
    @Value("${order.max-active-orders}")
    private int maxActiveOrders;
    
    @Value("${order.default-preparation-time}")
    private int defaultPreparationTime;

    @Transactional
    public Order createOrder(Order order) {
        validateOrder(order);
        calculateOrderTotals(order);
        setOrderTimestamps(order);
        return orderRepository.save(order);
    }

    public Order getOrder(String orderId) {
        return orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderException("Order not found: " + orderId));
    }

    public List<Order> getRestaurantOrders(String restaurantId) {
        return orderRepository.findByRestaurantId(restaurantId);
    }

    public List<Order> getCustomerOrders(String customerId) {
        return orderRepository.findByCustomerId(customerId);
    }

    @Transactional
    public Order updateOrderStatus(String orderId, String status) {
        Order order = getOrder(orderId);
        order.setStatus(status);
        order.setUpdatedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @Transactional
    public Order updatePaymentStatus(String orderId, String paymentStatus, String paymentId) {
        Order order = getOrder(orderId);
        order.setPaymentStatus(paymentStatus);
        order.setPaymentId(paymentId);
        order.setUpdatedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @Transactional
    public Order updateDeliveryStatus(String orderId, String deliveryStatus, String deliveryDriverId) {
        Order order = getOrder(orderId);
        order.setDeliveryStatus(deliveryStatus);
        order.setDeliveryDriverId(deliveryDriverId);
        order.setUpdatedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    private void validateOrder(Order order) {
        // Validate number of items
        if (order.getItems().size() > maxItemsPerOrder) {
            throw new OrderException("Order exceeds maximum items limit");
        }

        // Validate customer's order count
        long customerOrderCount = orderRepository.countByCustomerId(order.getCustomerId());
        if (customerOrderCount >= maxOrdersPerCustomer) {
            throw new OrderException("Customer has reached maximum order limit");
        }

        // Validate active orders
        List<Order> activeOrders = orderRepository.findByCustomerIdAndStatus(
            order.getCustomerId(), "ACTIVE");
        if (activeOrders.size() >= maxActiveOrders) {
            throw new OrderException("Customer has too many active orders");
        }
    }

    private void calculateOrderTotals(Order order) {
        BigDecimal subtotal = BigDecimal.ZERO;
        
        for (OrderItem item : order.getItems()) {
            BigDecimal itemSubtotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            item.setSubtotal(itemSubtotal);
            subtotal = subtotal.add(itemSubtotal);
        }
        
        order.setSubtotal(subtotal);
        
        // Calculate tax (assuming 8% tax rate)
        BigDecimal tax = subtotal.multiply(new BigDecimal("0.08"));
        order.setTax(tax);
        
        // Calculate delivery fee (assuming $5 flat rate)
        BigDecimal deliveryFee = new BigDecimal("5.00");
        order.setDeliveryFee(deliveryFee);
        
        // Calculate total
        BigDecimal total = subtotal.add(tax).add(deliveryFee);
        if (order.getDiscount() != null) {
            total = total.subtract(order.getDiscount());
        }
        order.setTotal(total);
    }

    private void setOrderTimestamps(Order order) {
        LocalDateTime now = LocalDateTime.now();
        order.setOrderTime(now);
        order.setCreatedAt(now);
        order.setUpdatedAt(now);
        order.setEstimatedDeliveryTime(now.plusMinutes(defaultPreparationTime));
    }
} 
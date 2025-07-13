#!/bin/bash

# Configuration
SERVICE_NAME="payment-service"
NAMESPACE="default"
LOG_FILE="/var/log/payment-service/certificate-monitor.log"
ALERT_EMAIL="admin@example.com"
CERT_DIR="/etc/ssl/payment-service"
WARNING_DAYS=45
CRITICAL_DAYS=30

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send alert
send_alert() {
    echo "Alert: $1" | mail -s "Payment Service Certificate Alert" $ALERT_EMAIL
}

# Function to check certificate validity
check_certificate_validity() {
    local cert_file="$CERT_DIR/tls.crt"
    local days_until_expiry
    
    if [ ! -f "$cert_file" ]; then
        log_message "Certificate file not found"
        send_alert "Certificate file not found"
        return 1
    fi
    
    days_until_expiry=$(openssl x509 -in "$cert_file" -noout -checkend $((WARNING_DAYS * 86400)) 2>&1)
    
    if [ $? -ne 0 ]; then
        if [ $days_until_expiry -le $CRITICAL_DAYS ]; then
            log_message "CRITICAL: Certificate will expire in $days_until_expiry days"
            send_alert "CRITICAL: Certificate will expire in $days_until_expiry days"
        else
            log_message "WARNING: Certificate will expire in $days_until_expiry days"
            send_alert "WARNING: Certificate will expire in $days_until_expiry days"
        fi
        return 1
    fi
    
    return 0
}

# Function to check certificate chain
check_certificate_chain() {
    local cert_file="$CERT_DIR/tls.crt"
    
    if ! openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt "$cert_file" > /dev/null 2>&1; then
        log_message "Certificate chain verification failed"
        send_alert "Certificate chain verification failed"
        return 1
    fi
    
    return 0
}

# Function to check certificate revocation
check_certificate_revocation() {
    local cert_file="$CERT_DIR/tls.crt"
    
    if ! openssl x509 -in "$cert_file" -noout -ocsp_uri | xargs curl -s > /dev/null 2>&1; then
        log_message "Certificate revocation check failed"
        send_alert "Certificate revocation check failed"
        return 1
    fi
    
    return 0
}

# Main monitoring process
log_message "Starting certificate monitoring..."

# Check certificate validity
if ! check_certificate_validity; then
    exit 1
fi

# Check certificate chain
if ! check_certificate_chain; then
    exit 1
fi

# Check certificate revocation
if ! check_certificate_revocation; then
    exit 1
fi

log_message "Certificate monitoring completed successfully" 
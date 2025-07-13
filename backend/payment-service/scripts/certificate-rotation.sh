#!/bin/bash

# Configuration
SERVICE_NAME="payment-service"
NAMESPACE="default"
LOG_FILE="/var/log/payment-service/certificate-rotation.log"
ALERT_EMAIL="admin@example.com"
CERT_DIR="/etc/ssl/payment-service"
CERT_BACKUP_DIR="/etc/ssl/payment-service/backup"
CERT_RENEWAL_THRESHOLD_DAYS=30

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send alert
send_alert() {
    echo "Alert: $1" | mail -s "Payment Service Certificate Rotation Alert" $ALERT_EMAIL
}

# Function to check certificate expiration
check_certificate_expiration() {
    local cert_file="$CERT_DIR/tls.crt"
    local days_until_expiry
    
    if [ ! -f "$cert_file" ]; then
        log_message "Certificate file not found"
        return 1
    fi
    
    days_until_expiry=$(openssl x509 -in "$cert_file" -noout -checkend $((CERT_RENEWAL_THRESHOLD_DAYS * 86400)) 2>&1)
    
    if [ $? -ne 0 ]; then
        log_message "Certificate will expire soon: $days_until_expiry"
        return 1
    fi
    
    return 0
}

# Function to backup current certificate
backup_certificate() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ ! -d "$CERT_BACKUP_DIR" ]; then
        mkdir -p "$CERT_BACKUP_DIR"
    fi
    
    cp "$CERT_DIR/tls.crt" "$CERT_BACKUP_DIR/tls.crt.$timestamp"
    cp "$CERT_DIR/tls.key" "$CERT_BACKUP_DIR/tls.key.$timestamp"
    
    log_message "Certificate backed up to $CERT_BACKUP_DIR"
}

# Function to request new certificate
request_new_certificate() {
    # Using Let's Encrypt for certificate issuance
    certbot certonly --standalone \
        -d api.payment-service.com \
        --agree-tos \
        --email $ALERT_EMAIL \
        --non-interactive \
        --preferred-challenges http
        
    if [ $? -ne 0 ]; then
        log_message "Failed to request new certificate"
        return 1
    fi
    
    return 0
}

# Function to update Kubernetes secret
update_kubernetes_secret() {
    local cert_file="/etc/letsencrypt/live/api.payment-service.com/fullchain.pem"
    local key_file="/etc/letsencrypt/live/api.payment-service.com/privkey.pem"
    
    # Create new secret
    kubectl create secret tls $SERVICE_NAME-tls \
        --cert="$cert_file" \
        --key="$key_file" \
        -n $NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
        
    if [ $? -ne 0 ]; then
        log_message "Failed to update Kubernetes secret"
        return 1
    fi
    
    return 0
}

# Function to verify certificate deployment
verify_certificate_deployment() {
    # Check if new certificate is being used
    local new_cert_hash=$(openssl x509 -in "$CERT_DIR/tls.crt" -noout -hash)
    local k8s_cert_hash=$(kubectl get secret $SERVICE_NAME-tls -n $NAMESPACE -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -hash)
    
    if [ "$new_cert_hash" != "$k8s_cert_hash" ]; then
        log_message "Certificate deployment verification failed"
        return 1
    fi
    
    return 0
}

# Function to rollback if needed
rollback_certificate() {
    local latest_backup=$(ls -t "$CERT_BACKUP_DIR/tls.crt.*" | head -n1)
    
    if [ -z "$latest_backup" ]; then
        log_message "No backup found for rollback"
        return 1
    fi
    
    cp "$latest_backup" "$CERT_DIR/tls.crt"
    cp "${latest_backup%.crt.*}.key.${latest_backup##*.}" "$CERT_DIR/tls.key"
    
    update_kubernetes_secret
    
    log_message "Certificate rolled back to previous version"
}

# Main rotation process
log_message "Starting certificate rotation process..."

# Check if rotation is needed
if check_certificate_expiration; then
    log_message "Certificate is still valid, no rotation needed"
    exit 0
fi

# Backup current certificate
backup_certificate

# Request new certificate
if ! request_new_certificate; then
    log_message "Failed to request new certificate, rolling back..."
    rollback_certificate
    send_alert "Certificate rotation failed"
    exit 1
fi

# Update Kubernetes secret
if ! update_kubernetes_secret; then
    log_message "Failed to update Kubernetes secret, rolling back..."
    rollback_certificate
    send_alert "Certificate rotation failed"
    exit 1
fi

# Verify deployment
if ! verify_certificate_deployment; then
    log_message "Certificate deployment verification failed, rolling back..."
    rollback_certificate
    send_alert "Certificate rotation failed"
    exit 1
fi

log_message "Certificate rotation completed successfully" 
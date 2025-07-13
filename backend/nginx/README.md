# Nginx Configuration for ForkLine

This repository contains the Nginx configuration for ForkLine's API Gateway with SSL support using Certbot.

## Project Structure

```
.
├── conf.d/               # Nginx configuration files
│   ├── default.conf     # Default server configuration
│   └── ssl.conf         # SSL configuration
├── ssl/                 # SSL certificates directory
├── logs/               # Nginx logs
├── .env               # Environment variables
└── docker-compose.yml # Docker compose configuration
```

## Setup Instructions

1. Install Certbot:
```bash
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
```

2. Obtain SSL Certificate:
```bash
sudo certbot --nginx -d www.forkline.com
```

3. Start the services:
```bash
docker-compose up -d
```

## Environment Variables

Create a `.env` file with the following variables:
- `DOMAIN_NAME`: Your domain name (www.forkline.com)
- `API_SERVICE_PORT`: Backend service port (3000)

## SSL Certificate Renewal

Certbot certificates are valid for 90 days. To renew:
```bash
sudo certbot renew
```

## Logs

- Access logs: `logs/access.log`
- Error logs: `logs/error.log`

## Security Best Practices

1. SSL/TLS configuration with modern protocols
2. HTTP/2 enabled
3. Security headers configured
4. Rate limiting implemented
5. Proxy headers properly set 
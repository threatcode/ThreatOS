#!/bin/bash

# Configuration
DOMAIN="mirrors.yourdomain.com"
EMAIL="your-email@example.com"

# Create necessary directories
mkdir -p ./tools/nginx/letsencrypt
mkdir -p ./tools/nginx/conf.d
mkdir -p ./tools/nginx/logs

# Create temporary Nginx config for HTTP challenge
cat > ./tools/nginx/conf.d/temp.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        root /var/www/certbot;
    }
}
EOF

# Start Nginx temporarily
docker-compose -f docker-compose.mirrorbits.yml up -d nginx

# Create webroot directory
docker-compose -f docker-compose.mirrorbits.yml run --rm --entrypoint "mkdir -p /var/www/certbot" certbot

# Get SSL certificate
docker-compose -f docker-compose.mirrorbits.yml run --rm \
  -e DOMAIN=$DOMAIN \
  -e EMAIL=$EMAIL \
  certbot certonly --webroot --webroot-path /var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN

# Replace the temporary config with the real one
cp ./tools/nginx/conf.d/mirrorbits.conf ./tools/nginx/conf.d/mirrorbits.conf.bak
cp ./tools/nginx/conf.d/mirrorbits.conf.example ./tools/nginx/conf.d/mirrorbits.conf

# Restart Nginx with SSL
docker-compose -f docker-compose.mirrorbits.yml down
docker-compose -f docker-compose.mirrorbits.yml up -d

echo "SSL setup complete!"
echo "Your Mirrorbits instance is now available at: https://$DOMAIN"

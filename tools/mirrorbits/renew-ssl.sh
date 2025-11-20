#!/bin/bash

# Renew certificates
docker-compose -f docker-compose.mirrorbits.yml run --rm certbot renew

# Reload Nginx to pick up the new certificates
docker-compose -f docker-compose.mirrorbits.yml exec nginx nginx -s reload

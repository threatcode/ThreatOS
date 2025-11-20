#!/bin/bash

# Initialize Mirrorbits

# Create necessary directories
sudo mkdir -p /srv/repository
sudo mkdir -p /var/lib/mirrorbits

# Set proper permissions
sudo chown -R $USER:$USER /srv/repository
sudo chown -R $USER:$USER /var/lib/mirrorbits

# Install required packages
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose
fi

# Build and start services
echo "Starting Mirrorbits with Docker Compose..."
docker-compose -f ../docker-compose.mirrorbits.yml up -d

echo "Mirrorbits is being initialized..."
echo "Waiting for services to start..."
sleep 10

# Initialize the database
echo "Initializing Mirrorbits database..."
docker-compose -f ../docker-compose.mirrorbits.yml exec mirrorbits mirrorbits -conf /etc/mirrorbits.conf init
docker-compose -f ../docker-compose.mirrorbits.yml exec mirrorbits mirrorbits -conf /etc/mirrorbits.conf update

echo "Mirrorbits setup complete!"
echo "Access the web interface at http://localhost:8080"
echo "To add mirrors, edit the configuration and run 'mirrorbits add' command"

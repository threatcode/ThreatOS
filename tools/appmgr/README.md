# ThreatOS Application Manager

A framework for managing containerized applications on ThreatOS and other Debian-based systems. This tool provides a simple, consistent way to deploy, manage, and maintain containerized applications using Docker Compose.

## Features

- **Simple Application Management**: Install, uninstall, start, stop, and manage containerized applications
- **Isolation**: Each application runs in its own isolated environment
- **Persistent Storage**: Automatic management of application data and logs
- **Easy Updates**: Simple commands to update applications
- **Logging**: Centralized logging for all applications
- **Security**: Runs with least privilege and follows security best practices

## Installation

1. Install Docker and Docker Compose if not already installed:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose (if not using the Docker Compose plugin)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. Install the ThreatOS Application Manager:

```bash
# Create the installation directory
sudo mkdir -p /opt/threatos/appmgr

# Copy the application manager script
sudo cp tools/appmgr/threatos-appmgr /usr/local/bin/threatos-appmgr
sudo chmod +x /usr/local/bin/threatos-appmgr

# Initialize the application manager
sudo threatos-appmgr init
```

## Usage

### Install an Application

```bash
# Install an application from a docker-compose.yml file
sudo threatos-appmgr install myapp /path/to/docker-compose.yml

# Start the application
sudo threatos-myapp up -d
```

### Manage Applications

```bash
# List all installed applications
sudo threatos-appmgr list

# Show status of an application
sudo threatos-appmgr status myapp

# Uninstall an application
sudo threatos-appmgr uninstall myapp
```

### Example: Install a Sample Application

```bash
# Create a sample application directory
mkdir -p ~/my-sample-app

# Create a docker-compose.yml file
cat > ~/my-sample-app/docker-compose.yml << 'EOL'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
EOL

# Install the application
sudo threatos-appmgr install sample-app ~/my-sample-app/docker-compose.yml

# Start the application
sudo threatos-sample-app up -d
```

## Directory Structure

The application manager uses the following directory structure:

```
/etc/threatos/apps/         # Application configurations
  └── app1/
      └── docker-compose.yml
  └── app2/
      └── docker-compose.yml

/var/lib/threatos/apps/     # Application data
  └── app1/
  └── app2/

/var/log/threatos/apps/     # Application logs
  └── app1/
  └── app2/
```

## Security Considerations

- The application manager should always be run with `sudo` to ensure proper permissions
- Each application runs in its own isolated network by default
- Application data is stored in `/var/lib/threatos/apps` with appropriate permissions
- Logs are stored in `/var/log/threatos/apps` and rotated automatically

## Best Practices

1. **Use Volumes for Persistent Data**: Always use Docker volumes for any data that needs to persist between container restarts.

2. **Limit Resource Usage**: Use Docker resource constraints to prevent any single application from consuming too many system resources.

3. **Regular Updates**: Regularly update your applications and their base images to ensure you have the latest security patches.

4. **Backup Important Data**: Regularly back up the contents of `/var/lib/threatos/apps` to prevent data loss.

5. **Monitor Resource Usage**: Use tools like `docker stats` to monitor the resource usage of your applications.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

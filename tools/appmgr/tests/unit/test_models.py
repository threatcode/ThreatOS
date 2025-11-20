"""Unit tests for data models."""

from datetime import datetime
import pytest

from appmgr.models import (
    Application,
    ApplicationConfig,
    ContainerSpec,
    VolumeSpec,
    Container,
    Image,
    Network,
    Volume
)

class TestVolumeSpec:
    """Tests for the VolumeSpec model."""
    
    def test_volume_spec_creation(self):
        """Test creating a VolumeSpec with valid data."""
        volume = VolumeSpec(
            source="/host/path",
            target="/container/path",
            type="bind",
            read_only=True
        )
        
        assert volume.source == "/host/path"
        assert volume.target == "/container/path"
        assert volume.type == "bind"
        assert volume.read_only is True
    
    def test_volume_spec_missing_target_raises_error(self):
        """Test that a VolumeSpec without a target raises an error."""
        with pytest.raises(ValueError, match="Volume target is required"):
            VolumeSpec(target="")  # type: ignore

class TestContainerSpec:
    """Tests for the ContainerSpec model."""
    
    def test_container_spec_creation(self):
        """Test creating a ContainerSpec with valid data."""
        container = ContainerSpec(
            name="web",
            image="nginx:alpine",
            command=["nginx", "-g", "daemon off;"],
            environment={"DEBUG": "true"},
            volumes=[
                VolumeSpec("web-data", "/data", "volume")
            ],
            ports={"80/tcp": 8080},
            depends_on=["db"],
            healthcheck={"test": ["CMD", "curl", "-f", "http://localhost"], "interval": 30000000000},
            restart_policy="on-failure",
            user="nginx",
            working_dir="/app"
        )
        
        assert container.name == "web"
        assert container.image == "nginx:alpine"
        assert container.command == ["nginx", "-g", "daemon off;"]
        assert container.environment == {"DEBUG": "true"}
        assert len(container.volumes) == 1
        assert container.volumes[0].source == "web-data"
        assert container.volumes[0].target == "/data"
        assert container.ports == {"80/tcp": 8080}
        assert container.depends_on == ["db"]
        assert container.healthcheck == {"test": ["CMD", "curl", "-f", "http://localhost"], "interval": 30000000000}
        assert container.restart_policy == "on-failure"
        assert container.user == "nginx"
        assert container.working_dir == "/app"

class TestApplicationConfig:
    """Tests for the ApplicationConfig model."""
    
    def test_application_config_creation(self):
        """Test creating an ApplicationConfig with valid data."""
        config = ApplicationConfig(
            id="test-app",
            name="Test Application",
            version="1.0.0",
            description="A test application",
            maintainer="test@example.com",
            containers=[
                ContainerSpec("web", "nginx:alpine")
            ],
            networks={
                "app-network": {"driver": "bridge"}
            },
            volumes={
                "web-data": {}
            },
            environment={
                "APP_ENV": "production"
            },
            labels={
                "com.example.vendor": "Test Vendor"
            }
        )
        
        assert config.id == "test-app"
        assert config.name == "Test Application"
        assert config.version == "1.0.0"
        assert config.description == "A test application"
        assert config.maintainer == "test@example.com"
        assert len(config.containers) == 1
        assert config.containers[0].name == "web"
        assert config.networks == {"app-network": {"driver": "bridge"}}
        assert config.volumes == {"web-data": {}}
        assert config.environment == {"APP_ENV": "production"}
        assert config.labels == {"com.example.vendor": "Test Vendor"}

class TestContainer:
    """Tests for the Container model."""
    
    def test_container_creation(self):
        """Test creating a Container with valid data."""
        image = Image(
            id="sha256:abc123",
            tags=["nginx:alpine"],
            created="2023-01-01T00:00:00Z",
            size=12345678
        )
        
        container = Container(
            id="abc123",
            name="test-container",
            image=image,
            status="running",
            state="running",
            created=datetime(2023, 1, 1),
            ports={"80/tcp": [{"HostIp": "0.0.0.0", "HostPort": "8080"}]},
            labels={"com.example.app": "test-app"},
            network_settings={"Networks": {"bridge": {"IPAddress": "172.17.0.2"}}}
        )
        
        assert container.id == "abc123"
        assert container.name == "test-container"
        assert container.image.id == "sha256:abc123"
        assert container.status == "running"
        assert container.state == "running"
        assert container.created.year == 2023
        assert container.ports["80/tcp"][0]["HostPort"] == "8080"
        assert container.labels["com.example.app"] == "test-app"
        assert container.network_settings["Networks"]["bridge"]["IPAddress"] == "172.17.0.2"

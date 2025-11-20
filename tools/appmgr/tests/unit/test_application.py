"""Unit tests for application management functionality."""

from pathlib import Path
from unittest.mock import MagicMock, patch, call
import pytest

from appmgr.core.application import ApplicationManager
from appmgr.core.exceptions import ApplicationError, ValidationError
from appmgr.models import Application, ApplicationConfig, ContainerSpec

class TestApplicationManager:
    """Tests for the ApplicationManager class."""
    
    def test_init_creates_config_dir(self, tmp_path):
        """Test that the config directory is created if it doesn't exist."""
        config_dir = tmp_path / "nonexistent"
        assert not config_dir.exists()
        
        manager = ApplicationManager(config_dir=config_dir)
        assert config_dir.exists()
    
    def test_init_no_runtimes_raises_error(self, monkeypatch):
        """Test that an error is raised if no container runtimes are available."""
        monkeypatch.setattr(
            'appmgr.core.runtime.get_available_runtimes',
            lambda: {}
        )
        
        with pytest.raises(ApplicationError, match="No container runtime"):
            ApplicationManager()
    
    def test_load_applications_empty_dir(self, app_manager):
        """Test loading applications from an empty directory."""
        assert len(app_manager.applications) == 0
    
    def test_load_applications_invalid_config(self, app_manager, tmp_path):
        """Test loading applications with invalid configuration."""
        # Create an invalid config file
        app_dir = tmp_path / "config" / "test-app"
        app_dir.mkdir(parents=True)
        (app_dir / "app.yaml").write_text("invalid: yaml: :")
        
        # Should log an error but not crash
        app_manager._load_applications()
        assert len(app_manager.applications) == 0
    
    def test_create_application_missing_required_fields(self, app_manager):
        """Test validation of required fields in application config."""
        # Missing 'id' field
        config = {
            "name": "Test App",
            "version": "1.0.0",
            "containers": []
        }
        
        with pytest.raises(ValidationError, match="Missing required field: id"):
            app_manager._create_application(config, Path("/tmp"))
    
    def test_create_application_valid_config(self, app_manager, sample_app_config):
        """Test creating an application from a valid config."""
        app = app_manager._create_application(sample_app_config, Path("/tmp"))
        
        assert isinstance(app, Application)
        assert app.id == "test-app"
        assert app.name == "Test Application"
        assert app.version == "1.0.0"
        assert len(app.config.containers) == 1
        assert app.config.containers[0].name == "web"
        assert app.config.containers[0].image == "nginx:alpine"
    
    @patch('appmgr.core.runtime.DockerRuntime')
    def test_start_application_success(self, mock_docker_runtime, app_manager, sample_app_config):
        """Test starting an application successfully."""
        # Add a test application to the manager
        app = app_manager._create_application(sample_app_config, Path("/tmp"))
        app_manager.applications[app.id] = app
        
        # Mock the container runtime
        runtime = MagicMock()
        runtime.pull_image.return_value = MagicMock(id="sha256:test")
        app_manager.runtimes = {"docker": runtime}
        app_manager.default_runtime = runtime
        
        # Test starting the application
        result = app_manager.start_application("test-app")
        
        assert result is True
        runtime.pull_image.assert_called_once_with("nginx", tag="alpine")
    
    def test_start_application_not_found(self, app_manager):
        """Test starting a non-existent application."""
        with pytest.raises(ApplicationError, match="Application not found"):
            app_manager.start_application("nonexistent-app")

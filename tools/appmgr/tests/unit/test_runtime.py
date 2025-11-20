"""Unit tests for container runtime functionality."""

from unittest.mock import MagicMock, patch
import pytest
from docker.errors import APIError

from appmgr.core.runtime import ContainerRuntime, DockerRuntime, get_available_runtimes
from appmgr.core.exceptions import ContainerRuntimeError

class TestContainerRuntime:
    """Tests for the ContainerRuntime abstract base class."""
    
    def test_abstract_methods(self):
        """Test that ContainerRuntime raises NotImplementedError for abstract methods."""
        runtime = ContainerRuntime("test")
        
        with pytest.raises(NotImplementedError):
            runtime.connect()
            
        with pytest.raises(NotImplementedError):
            runtime.is_available()
            
        with pytest.raises(NotImplementedError):
            runtime.pull_image("test-image")

class TestDockerRuntime:
    """Tests for the DockerRuntime class."""
    
    @patch('docker.from_env')
    def test_connect_success(self, mock_from_env):
        """Test successful connection to Docker daemon."""
        mock_client = MagicMock()
        mock_client.ping.return_value = True
        mock_from_env.return_value = mock_client
        
        runtime = DockerRuntime()
        assert runtime.connect() is True
        assert runtime.connected is True
        mock_client.ping.assert_called_once()
    
    @patch('docker.from_env')
    def test_connect_failure(self, mock_from_env):
        """Test failed connection to Docker daemon."""
        mock_from_env.side_effect = Exception("Connection failed")
        
        runtime = DockerRuntime()
        assert runtime.connect() is False
        assert runtime.connected is False
    
    @patch('importlib.import_module')
    def test_is_available(self, mock_import):
        """Test Docker availability check."""
        # Test when docker module is available
        runtime = DockerRuntime()
        assert runtime.is_available() is True
        
        # Test when docker module is not available
        mock_import.side_effect = ImportError()
        assert runtime.is_available() is False
    
    @patch('docker.DockerClient.images.pull')
    def test_pull_image_success(self, mock_pull):
        """Test successful image pull."""
        mock_image = MagicMock()
        mock_image.short_id = "sha256:abc123"
        mock_image.tags = ["test-image:latest"]
        mock_image.attrs = {
            'Created': '2023-01-01T00:00:00Z',
            'Size': 12345678
        }
        mock_pull.return_value = mock_image
        
        runtime = DockerRuntime()
        runtime._client = MagicMock()  # Pretend we're connected
        runtime.connected = True
        
        image = runtime.pull_image("test-image")
        
        assert image.id == "sha256:abc123"
        assert image.tags == ["test-image:latest"]
        mock_pull.assert_called_once_with("test-image", tag="latest")
    
    @patch('docker.DockerClient.images.pull')
    def test_pull_image_failure(self, mock_pull):
        """Test failed image pull."""
        mock_pull.side_effect = Exception("Pull failed")
        
        runtime = DockerRuntime()
        runtime._client = MagicMock()  # Pretend we're connected
        runtime.connected = True
        
        with pytest.raises(ContainerRuntimeError, match="Failed to pull image"):
            runtime.pull_image("test-image")

class TestGetAvailableRuntimes:
    """Tests for the get_available_runtimes function."""
    
    @patch('appmgr.core.runtime.DockerRuntime.is_available', return_value=True)
    @patch('appmgr.core.runtime.DockerRuntime.connect', return_value=True)
    @patch('appmgr.core.runtime.PodmanRuntime.is_available', return_value=False)
    def test_only_docker_available(self, mock_podman_avail, mock_docker_connect, mock_docker_avail):
        """Test when only Docker is available."""
        runtimes = get_available_runtimes()
        assert len(runtimes) == 1
        assert "docker" in runtimes
        assert isinstance(runtimes["docker"], DockerRuntime)
    
    @patch('appmgr.core.runtime.DockerRuntime.is_available', return_value=False)
    @patch('appmgr.core.runtime.PodmanRuntime.is_available', return_value=True)
    @patch('appmgr.core.runtime.PodmanRuntime.connect', return_value=True)
    def test_only_podman_available(self, mock_podman_connect, mock_podman_avail, mock_docker_avail):
        """Test when only Podman is available."""
        runtimes = get_available_runtimes()
        assert len(runtimes) == 1
        assert "podman" in runtimes
        assert isinstance(runtimes["podman"], PodmanRuntime)
    
    @patch('appmgr.core.runtime.DockerRuntime.is_available', return_value=True)
    @patch('appmgr.core.runtime.DockerRuntime.connect', return_value=True)
    @patch('appmgr.core.runtime.PodmanRuntime.is_available', return_value=True)
    @patch('appmgr.core.runtime.PodmanRuntime.connect', return_value=True)
    def test_both_available(self, mock_podman_connect, mock_podman_avail, mock_docker_connect, mock_docker_avail):
        """Test when both Docker and Podman are available."""
        runtimes = get_available_runtimes()
        assert len(runtimes) == 2
        assert "docker" in runtimes
        assert "podman" in runtimes
        assert isinstance(runtimes["docker"], DockerRuntime)
        assert isinstance(runtimes["podman"], PodmanRuntime)
    
    @patch('appmgr.core.runtime.DockerRuntime.is_available', return_value=False)
    @patch('appmgr.core.runtime.PodmanRuntime.is_available', return_value=False)
    def test_none_available(self, mock_podman_avail, mock_docker_avail):
        """Test when no container runtimes are available."""
        runtimes = get_available_runtimes()
        assert len(runtimes) == 0

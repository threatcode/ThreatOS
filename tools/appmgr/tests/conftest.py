"""Pytest configuration and fixtures for ThreatOS Application Manager tests."""

import os
import shutil
import tempfile
from pathlib import Path
from typing import Generator

import pytest
from docker import DockerClient

from appmgr.core.runtime import ContainerRuntime, DockerRuntime, PodmanRuntime
from appmgr.core.application import ApplicationManager

@pytest.fixture(scope="session")
def test_data_dir() -> Path:
    """Return the path to the test data directory."""
    return Path(__file__).parent / "data"

@pytest.fixture(scope="session")
def temp_dir() -> Generator[Path, None, None]:
    """Create and return a temporary directory for testing."""
    temp_dir = tempfile.mkdtemp(prefix="threatos-appmgr-test-")
    temp_path = Path(temp_dir)
    yield temp_path
    shutil.rmtree(temp_path, ignore_errors=True)

@pytest.fixture(scope="session")
def docker_client() -> DockerClient:
    """Return a Docker client for testing."""
    try:
        from docker import from_env
        client = from_env()
        client.ping()  # Verify connection
        return client
    except Exception as e:
        pytest.skip(f"Docker not available: {e}")

@pytest.fixture(scope="session")
def docker_runtime(docker_client: DockerClient) -> DockerRuntime:
    """Return a Docker runtime instance for testing."""
    runtime = DockerRuntime()
    if not runtime.connect():
        pytest.skip("Failed to connect to Docker daemon")
    return runtime

@pytest.fixture(scope="session")
def podman_runtime() -> PodmanRuntime:
    """Return a Podman runtime instance for testing if available."""
    runtime = PodmanRuntime()
    if not runtime.is_available() or not runtime.connect():
        pytest.skip("Podman not available or failed to connect")
    return runtime

@pytest.fixture
def app_manager(temp_dir: Path) -> ApplicationManager:
    """Return an ApplicationManager instance with a temporary config directory."""
    config_dir = temp_dir / "config"
    config_dir.mkdir()
    return ApplicationManager(config_dir=config_dir)

@pytest.fixture
def sample_app_config() -> dict:
    """Return a sample application configuration for testing."""
    return {
        "id": "test-app",
        "name": "Test Application",
        "version": "1.0.0",
        "description": "A test application",
        "maintainer": "test@example.com",
        "containers": [
            {
                "name": "web",
                "image": "nginx:alpine",
                "ports": {"80/tcp": 8080},
                "volumes": [
                    {"source": "web-data", "target": "/data", "type": "volume"}
                ],
                "environment": {
                    "ENV": "test"
                }
            }
        ],
        "networks": {
            "app-network": {
                "driver": "bridge"
            }
        },
        "volumes": {
            "web-data": {}
        }
    }

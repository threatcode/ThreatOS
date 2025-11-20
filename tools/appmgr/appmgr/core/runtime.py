"""Container runtime abstraction layer."""

import abc
import logging
from typing import Dict, List, Optional, Any, Union
from pathlib import Path

from ..models import Container, Image, Volume, Network

logger = logging.getLogger(__name__)

class ContainerRuntime(abc.ABC):
    """Abstract base class for container runtimes."""
    
    def __init__(self, runtime_name: str):
        self.runtime_name = runtime_name
        self.connected = False
        
    @abc.abstractmethod
    def connect(self) -> bool:
        """Connect to the container runtime."""
        pass
    
    @abc.abstractmethod
    def is_available(self) -> bool:
        """Check if the runtime is available on the system."""
        pass
    
    @abc.abstractmethod
    def pull_image(self, image_name: str, tag: str = "latest") -> Image:
        """Pull a container image from a registry."""
        pass
    
    @abc.abstractmethod
    def run_container(
        self,
        image: str,
        name: Optional[str] = None,
        command: Optional[Union[str, List[str]]] = None,
        environment: Optional[Dict[str, str]] = None,
        volumes: Optional[Dict[str, Dict[str, str]]] = None,
        ports: Optional[Dict[str, Union[int, str]]] = None,
        detach: bool = False,
        remove: bool = False,
        **kwargs
    ) -> Container:
        """Run a container with the given configuration."""
        pass
    
    @abc.abstractmethod
    def stop_container(self, container_id: str, timeout: int = 10) -> bool:
        """Stop a running container."""
        pass
    
    @abc.abstractmethod
    def remove_container(self, container_id: str, force: bool = False) -> bool:
        """Remove a container."""
        pass
    
    @abc.abstractmethod
    def list_containers(self, all: bool = False, filters: Optional[Dict] = None) -> List[Container]:
        """List containers."""
        pass
    
    @abc.abstractmethod
    def get_container(self, container_id: str) -> Optional[Container]:
        """Get a container by ID."""
        pass
    
    @abc.abstractmethod
    def get_container_logs(
        self, 
        container_id: str, 
        follow: bool = False, 
        tail: Optional[int] = None
    ) -> str:
        """Get logs from a container."""
        pass


class DockerRuntime(ContainerRuntime):
    """Docker container runtime implementation."""
    
    def __init__(self):
        super().__init__("docker")
        self._client = None
    
    def connect(self) -> bool:
        try:
            import docker
            self._client = docker.from_env()
            self._client.ping()
            self.connected = True
            logger.info("Connected to Docker daemon")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Docker: {e}")
            self.connected = False
            return False
    
    def is_available(self) -> bool:
        try:
            import docker
            return True
        except ImportError:
            return False
    
    def pull_image(self, image_name: str, tag: str = "latest") -> Image:
        if not self.connected and not self.connect():
            raise ContainerRuntimeError("Not connected to Docker daemon")
            
        full_image = f"{image_name}:{tag}"
        logger.info(f"Pulling image {full_image}")
        
        try:
            image = self._client.images.pull(image_name, tag=tag)
            return Image(
                id=image.short_id,
                tags=image.tags,
                created=image.attrs['Created'],
                size=image.attrs['Size']
            )
        except Exception as e:
            logger.error(f"Failed to pull image {full_image}: {e}")
            raise ContainerRuntimeError(f"Failed to pull image {full_image}: {e}")


class PodmanRuntime(ContainerRuntime):
    """Podman container runtime implementation."""
    
    def __init__(self):
        super().__init__("podman")
        self._client = None
    
    def connect(self) -> bool:
        try:
            import podman
            self._client = podman.PodmanClient()
            self._client.ping()
            self.connected = True
            logger.info("Connected to Podman service")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Podman: {e}")
            self.connected = False
            return False
    
    def is_available(self) -> bool:
        try:
            import podman
            return True
        except ImportError:
            return False
    
    # Implement other required methods similar to DockerRuntime
    # ...


def get_available_runtimes() -> Dict[str, ContainerRuntime]:
    """Get a dictionary of available container runtimes."""
    runtimes = {}
    
    # Check for Docker
    docker_rt = DockerRuntime()
    if docker_rt.is_available() and docker_rt.connect():
        runtimes["docker"] = docker_rt
    
    # Check for Podman
    podman_rt = PodmanRuntime()
    if podman_rt.is_available() and podman_rt.connect():
        runtimes["podman"] = podman_rt
    
    return runtimes

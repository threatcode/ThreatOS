"""Application management functionality."""

import logging
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Any, Union

from .exceptions import ApplicationError, ConfigurationError, ValidationError
from .runtime import ContainerRuntime, get_available_runtimes
from ..models import Application, ApplicationConfig, ContainerSpec, VolumeSpec
from ..utils.config import load_config, save_config

logger = logging.getLogger(__name__)

class ApplicationManager:
    """Manages containerized applications."""
    
    def __init__(self, config_dir: Optional[Union[str, Path]] = None):
        """Initialize the application manager.
        
        Args:
            config_dir: Directory containing application configurations.
        """
        self.config_dir = Path(config_dir) if config_dir else Path.home() / ".config" / "threatos" / "apps"
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        self.runtimes = get_available_runtimes()
        if not self.runtimes:
            raise ApplicationError("No container runtime (Docker/Podman) is available")
            
        self.default_runtime = next(iter(self.runtimes.values()))
        logger.info(f"Using container runtime: {self.default_runtime.runtime_name}")
        
        self.applications: Dict[str, Application] = {}
        self._load_applications()
    
    def _load_applications(self) -> None:
        """Load all application configurations from the config directory."""
        self.applications.clear()
        
        for config_file in self.config_dir.glob("*/app.yaml"):
            try:
                app_config = load_config(config_file)
                app = self._create_application(app_config, config_file.parent)
                self.applications[app.id] = app
                logger.info(f"Loaded application: {app.id} (v{app.version})")
            except Exception as e:
                logger.error(f"Failed to load application from {config_file}: {e}")
    
    def _create_application(self, config_data: Dict[str, Any], config_dir: Path) -> Application:
        """Create an Application instance from configuration data."""
        # Validate required fields
        required_fields = ["id", "name", "version", "containers"]
        for field in required_fields:
            if field not in config_data:
                raise ValidationError(f"Missing required field: {field}")
        
        # Parse container specs
        containers = []
        for container_data in config_data.get("containers", []):
            container = ContainerSpec(
                name=container_data.get("name"),
                image=container_data["image"],
                command=container_data.get("command"),
                environment=container_data.get("environment", {}),
                volumes=[
                    VolumeSpec(
                        source=vol.get("source"),
                        target=vol["target"],
                        type=vol.get("type", "volume"),
                        read_only=vol.get("read_only", False)
                    )
                    for vol in container_data.get("volumes", [])
                ],
                ports=container_data.get("ports", {}),
                depends_on=container_data.get("depends_on", []),
                healthcheck=container_data.get("healthcheck"),
                restart_policy=container_data.get("restart", "no")
            )
            containers.append(container)
        
        # Create application config
        app_config = ApplicationConfig(
            id=config_data["id"],
            name=config_data["name"],
            version=config_data["version"],
            description=config_data.get("description"),
            maintainer=config_data.get("maintainer"),
            containers=containers,
            networks=config_data.get("networks", {}),
            volumes=config_data.get("volumes", {}),
            environment=config_data.get("environment", {})
        )
        
        return Application(config=app_config, config_dir=config_dir)
    
    def install_application(
        self, 
        source: Union[str, Path], 
        runtime: Optional[str] = None
    ) -> Application:
        """Install an application from a source directory or URL."""
        # TODO: Implement application installation
        pass
    
    def uninstall_application(self, app_id: str, remove_data: bool = False) -> bool:
        """Uninstall an application."""
        # TODO: Implement application uninstallation
        pass
    
    def start_application(
        self, 
        app_id: str, 
        runtime: Optional[str] = None,
        detach: bool = True
    ) -> bool:
        """Start an application."""
        if app_id not in self.applications:
            raise ApplicationError(f"Application not found: {app_id}")
        
        app = self.applications[app_id]
        rt = self._get_runtime(runtime)
        
        try:
            # Pull required images
            for container in app.config.containers:
                rt.pull_image(container.image)
            
            # Start containers
            # TODO: Implement container startup with dependencies
            
            logger.info(f"Started application: {app_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to start application {app_id}: {e}")
            raise ApplicationError(f"Failed to start application: {e}")
    
    def stop_application(self, app_id: str, timeout: int = 10) -> bool:
        """Stop a running application."""
        # TODO: Implement application stop
        pass
    
    def _get_runtime(self, runtime_name: Optional[str] = None) -> ContainerRuntime:
        """Get a container runtime by name or return the default."""
        if runtime_name:
            if runtime_name not in self.runtimes:
                raise ApplicationError(f"Unsupported container runtime: {runtime_name}")
            return self.runtimes[runtime_name]
        return self.default_runtime

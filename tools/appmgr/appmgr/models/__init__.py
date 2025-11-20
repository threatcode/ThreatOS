"""Data models for the ThreatOS Application Manager."""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Dict, List, Optional, Any

__all__ = [
    'Application',
    'ApplicationConfig',
    'Container',
    'ContainerSpec',
    'Image',
    'Network',
    'Volume',
    'VolumeSpec',
]

@dataclass
class Application:
    """Represents a containerized application."""
    config: 'ApplicationConfig'
    config_dir: str
    state: Dict[str, Any] = field(default_factory=dict)
    
    @property
    def id(self) -> str:
        return self.config.id
    
    @property
    def name(self) -> str:
        return self.config.name
    
    @property
    def version(self) -> str:
        return self.config.version

@dataclass
class ApplicationConfig:
    """Configuration for a containerized application."""
    id: str
    name: str
    version: str
    description: Optional[str] = None
    maintainer: Optional[str] = None
    containers: List['ContainerSpec'] = field(default_factory=list)
    networks: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    volumes: Dict[str, Dict[str, Any]] = field(default_factory=dict)
    environment: Dict[str, str] = field(default_factory=dict)
    labels: Dict[str, str] = field(default_factory=dict)

@dataclass
class ContainerSpec:
    """Specification for a container in an application."""
    name: str
    image: str
    command: Optional[Union[str, List[str]]] = None
    environment: Dict[str, str] = field(default_factory=dict)
    volumes: List['VolumeSpec'] = field(default_factory=list)
    ports: Dict[str, Union[int, str]] = field(default_factory=dict)
    depends_on: List[str] = field(default_factory=list)
    healthcheck: Optional[Dict[str, Any]] = None
    restart_policy: str = "no"
    user: Optional[str] = None
    working_dir: Optional[str] = None

@dataclass
class VolumeSpec:
    """Volume specification for a container."""
    source: Optional[str] = None
    target: str
    type: str = "volume"  # 'volume', 'bind', 'tmpfs', 'npipe', or 'cluster'
    read_only: bool = False
    
    def __post_init__(self):
        if not self.target:
            raise ValueError("Volume target is required")

@dataclass
class Container:
    """Represents a running or stopped container."""
    id: str
    name: str
    image: 'Image'
    status: str
    state: str
    created: datetime
    ports: Dict[str, List[Dict[str, str]]]
    labels: Dict[str, str]
    network_settings: Dict[str, Any]

@dataclass
class Image:
    """Represents a container image."""
    id: str
    tags: List[str]
    created: str
    size: int
    labels: Dict[str, str] = field(default_factory=dict)

@dataclass
class Network:
    """Represents a container network."""
    id: str
    name: str
    driver: str
    scope: str
    labels: Dict[str, str] = field(default_factory=dict)
    options: Dict[str, str] = field(default_factory=dict)

@dataclass
class Volume:
    """Represents a volume."""
    name: str
    driver: str
    mountpoint: str
    labels: Dict[str, str] = field(default_factory=dict)
    options: Dict[str, str] = field(default_factory=dict)
    created: Optional[datetime] = None

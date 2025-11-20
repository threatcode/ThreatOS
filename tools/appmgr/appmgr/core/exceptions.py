"""Custom exceptions for the ThreatOS Application Manager."""

class AppManagerError(Exception):
    """Base exception for all application manager errors."""
    pass

class ApplicationError(AppManagerError):
    """Raised when there's an error with application management."""
    pass

class ContainerRuntimeError(AppManagerError):
    """Raised when there's an error with the container runtime."""
    pass

class RegistryError(AppManagerError):
    """Raised when there's an error with container registry operations."""
    pass

class ConfigurationError(AppManagerError):
    """Raised when there's an error with configuration."""
    pass

class ValidationError(AppManagerError):
    """Raised when validation of input data fails."""
    pass

class PluginError(AppManagerError):
    """Raised when there's an error with plugins."""
    pass

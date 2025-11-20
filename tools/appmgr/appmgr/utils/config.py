"""Configuration utilities for the ThreatOS Application Manager."""

import logging
import os
import yaml
from pathlib import Path
from typing import Any, Dict, Optional, Union

logger = logging.getLogger(__name__)

def load_config(file_path: Union[str, Path]) -> Dict[str, Any]:
    """Load a YAML configuration file.
    
    Args:
        file_path: Path to the YAML file.
        
    Returns:
        The parsed configuration as a dictionary.
        
    Raises:
        FileNotFoundError: If the file does not exist.
        yaml.YAMLError: If the file contains invalid YAML.
    """
    file_path = Path(file_path)
    if not file_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {file_path}")
    
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f) or {}
    except yaml.YAMLError as e:
        logger.error(f"Failed to parse YAML file {file_path}: {e}")
        raise

def save_config(config: Dict[str, Any], file_path: Union[str, Path]) -> None:
    """Save a dictionary to a YAML configuration file.
    
    Args:
        config: The configuration dictionary to save.
        file_path: Path to save the YAML file to.
        
    Raises:
        IOError: If the file cannot be written.
    """
    file_path = Path(file_path)
    file_path.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        with open(file_path, 'w') as f:
            yaml.safe_dump(config, f, default_flow_style=False, sort_keys=False)
    except IOError as e:
        logger.error(f"Failed to write configuration to {file_path}: {e}")
        raise

def merge_configs(base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
    """Recursively merge two configuration dictionaries.
    
    Args:
        base: The base configuration dictionary.
        override: The configuration dictionary with override values.
        
    Returns:
        A new dictionary with the merged configuration.
    """
    result = base.copy()
    
    for key, value in override.items():
        if key in base and isinstance(base[key], dict) and isinstance(value, dict):
            result[key] = merge_configs(base[key], value)
        else:
            result[key] = value
    
    return result

def load_environment_vars(prefix: str = "THREATOS_") -> Dict[str, str]:
    """Load environment variables with a specific prefix.
    
    Args:
        prefix: The prefix to filter environment variables by.
        
    Returns:
        A dictionary of environment variables with the prefix removed.
    """
    prefix = prefix.upper()
    return {
        k[len(prefix):].lower(): v 
        for k, v in os.environ.items() 
        if k.startswith(prefix)
    }

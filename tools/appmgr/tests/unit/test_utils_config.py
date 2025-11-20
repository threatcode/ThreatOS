"""Unit tests for configuration utilities."""

import os
import tempfile
from pathlib import Path

import pytest
import yaml

from appmgr.utils.config import load_config, save_config, merge_configs, load_environment_vars

def test_load_config_valid_file():
    """Test loading a valid YAML configuration file."""
    # Create a temporary YAML file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        f.write("""
        app:
          name: Test App
          version: 1.0.0
          enabled: true
        """)
        temp_file = f.name
    
    try:
        config = load_config(temp_file)
        assert config["app"]["name"] == "Test App"
        assert config["app"]["version"] == "1.0.0"
        assert config["app"]["enabled"] is True
    finally:
        os.unlink(temp_file)

def test_load_config_invalid_yaml():
    """Test loading an invalid YAML file raises an exception."""
    # Create a temporary invalid YAML file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
        f.write("invalid: yaml: :")
        temp_file = f.name
    
    try:
        with pytest.raises(yaml.YAMLError):
            load_config(temp_file)
    finally:
        os.unlink(temp_file)

def test_load_config_nonexistent_file():
    """Test loading a non-existent file raises FileNotFoundError."""
    with pytest.raises(FileNotFoundError):
        load_config("/nonexistent/file.yaml")

def test_save_config():
    """Test saving a configuration to a file."""
    config = {
        "app": {
            "name": "Test App",
            "version": "1.0.0",
            "enabled": True
        }
    }
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / "config.yaml"
        save_config(config, config_file)
        
        assert config_file.exists()
        
        # Verify the saved content
        with open(config_file, 'r') as f:
            saved_config = yaml.safe_load(f)
            
        assert saved_config["app"]["name"] == "Test App"
        assert saved_config["app"]["version"] == "1.0.0"
        assert saved_config["app"]["enabled"] is True

def test_merge_configs():
    """Test merging two configuration dictionaries."""
    base = {
        "app": {
            "name": "Base App",
            "version": "1.0.0",
            "settings": {
                "debug": False,
                "log_level": "info"
            }
        }
    }
    
    override = {
        "app": {
            "version": "2.0.0",
            "settings": {
                "debug": True
            },
            "new_setting": "value"
        },
        "new_section": {
            "key": "value"
        }
    }
    
    merged = merge_configs(base, override)
    
    # Original base should not be modified
    assert base["app"]["version"] == "1.0.0"
    
    # Check merged values
    assert merged["app"]["name"] == "Base App"  # From base
    assert merged["app"]["version"] == "2.0.0"  # Overridden
    assert merged["app"]["settings"]["debug"] is True  # Nested override
    assert merged["app"]["settings"]["log_level"] == "info"  # Nested from base
    assert merged["app"]["new_setting"] == "value"  # New key
    assert merged["new_section"]["key"] == "value"  # New section

def test_load_environment_vars():
    """Test loading environment variables with a specific prefix."""
    # Set up test environment variables
    test_vars = {
        "THREATOS_APP_NAME": "Test App",
        "THREATOS_APP_VERSION": "1.0.0",
        "THREATOS_DEBUG": "true",
        "OTHER_VAR": "should_not_appear"
    }
    
    # Apply the test environment
    for key, value in test_vars.items():
        os.environ[key] = value
    
    try:
        # Test with default prefix
        config = load_environment_vars("THREATOS_")
        
        assert config["app_name"] == "Test App"
        assert config["app_version"] == "1.0.0"
        assert config["debug"] == "true"
        assert "other_var" not in config
        
        # Test with different prefix
        config = load_environment_vars("NONEXISTENT_")
        assert config == {}
        
    finally:
        # Clean up
        for key in test_vars:
            os.environ.pop(key, None)

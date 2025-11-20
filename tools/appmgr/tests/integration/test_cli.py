"""Integration tests for the CLI interface."""

import os
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest
from click.testing import CliRunner

from appmgr.cli.main import cli

class TestCLI:
    """Tests for the CLI interface."""
    
    @pytest.fixture
    def runner(self):
        """Fixture for invoking the CLI."""
        return CliRunner()
    
    def test_help(self, runner):
        """Test the --help flag."""
        result = runner.invoke(cli, ["--help"])
        assert result.exit_code == 0
        assert "Show this message and exit." in result.output
    
    def test_version(self, runner):
        """Test the --version flag."""
        result = runner.invoke(cli, ["--version"])
        assert result.exit_code == 0
        assert "version" in result.output.lower()
    
    @patch('appmgr.core.application.ApplicationManager')
    def test_start_command(self, mock_manager_class, runner, tmp_path):
        """Test the start command."""
        # Setup mock
        mock_manager = MagicMock()
        mock_manager_class.return_value = mock_manager
        
        # Create a temporary config directory
        config_dir = tmp_path / "config"
        config_dir.mkdir()
        
        # Run the command
        result = runner.invoke(
            cli,
            ["--config-dir", str(config_dir), "start", "test-app"],
            catch_exceptions=False
        )
        
        # Verify the result
        assert result.exit_code == 0
        mock_manager_class.assert_called_once_with(config_dir=config_dir)
        mock_manager.start_application.assert_called_once_with(
            "test-app", runtime=None, detach=True
        )
    
    @patch('appmgr.core.application.ApplicationManager')
    def test_stop_command(self, mock_manager_class, runner, tmp_path):
        """Test the stop command."""
        # Setup mock
        mock_manager = MagicMock()
        mock_manager_class.return_value = mock_manager
        
        # Create a temporary config directory
        config_dir = tmp_path / "config"
        config_dir.mkdir()
        
        # Run the command
        result = runner.invoke(
            cli,
            ["--config-dir", str(config_dir), "stop", "test-app"],
            catch_exceptions=False
        )
        
        # Verify the result
        assert result.exit_code == 0
        mock_manager.stop_application.assert_called_once_with("test-app", timeout=10)
    
    @patch('appmgr.core.application.ApplicationManager')
    def test_install_command(self, mock_manager_class, runner, tmp_path):
        """Test the install command."""
        # Setup mock
        mock_manager = MagicMock()
        mock_manager_class.return_value = mock_manager
        
        # Create a temporary source directory
        source_dir = tmp_path / "source"
        source_dir.mkdir()
        
        # Create a temporary config directory
        config_dir = tmp_path / "config"
        
        # Run the command
        result = runner.invoke(
            cli,
            ["--config-dir", str(config_dir), "install", str(source_dir)],
            catch_exceptions=False
        )
        
        # Verify the result
        assert result.exit_code == 0
        mock_manager.install_application.assert_called_once_with(
            str(source_dir), runtime=None
        )
    
    @patch('appmgr.core.application.ApplicationManager')
    def test_uninstall_command(self, mock_manager_class, runner, tmp_path):
        """Test the uninstall command."""
        # Setup mock
        mock_manager = MagicMock()
        mock_manager_class.return_value = mock_manager
        
        # Create a temporary config directory
        config_dir = tmp_path / "config"
        
        # Run the command
        result = runner.invoke(
            cli,
            ["--config-dir", str(config_dir), "uninstall", "test-app"],
            catch_exceptions=False
        )
        
        # Verify the result
        assert result.exit_code == 0
        mock_manager.uninstall_application.assert_called_once_with(
            "test-app", remove_data=False
        )
    
    def test_logging_setup(self, runner, tmp_path):
        """Test that logging is properly set up."""
        # Create a temporary log file
        log_file = tmp_path / "appmgr.log"
        
        # Run a command that will trigger logging
        result = runner.invoke(
            cli,
            [
                "--log-level", "debug",
                "--log-file", str(log_file),
                "--config-dir", str(tmp_path / "config"),
                "start", "test-app"
            ],
            catch_exceptions=False
        )
        
        # The command will fail because we don't have a real application,
        # but we just want to check the log file was created
        assert log_file.exists()
        
        # Check that the log file contains some expected content
        log_content = log_file.read_text()
        assert "Starting test-app..." in log_content or "Application not found" in log_content

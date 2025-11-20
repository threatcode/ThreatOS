"""Unit tests for logging utilities."""

import logging
import os
import tempfile
from pathlib import Path

import pytest

from appmgr.utils.logging import setup_logging, LoggingContext, get_logger

def test_setup_logging_console():
    """Test setting up console logging."""
    # Clear existing handlers
    root_logger = logging.getLogger()
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Setup console logging
    setup_logging(level="debug")
    
    # Verify console handler is configured
    console_handlers = [
        h for h in root_logger.handlers 
        if isinstance(h, logging.StreamHandler)
    ]
    assert len(console_handlers) == 1
    assert root_logger.level == logging.DEBUG

def test_setup_logging_file():
    """Test setting up file logging."""
    with tempfile.TemporaryDirectory() as temp_dir:
        log_file = Path(temp_dir) / "test.log"
        
        # Setup file logging
        setup_logging(level="info", log_file=log_file)
        
        # Log a test message
        test_message = "Test log message"
        logger = logging.getLogger("test_logger")
        logger.info(test_message)
        
        # Force flush to ensure the message is written
        for handler in logging.getLogger().handlers:
            handler.flush()
        
        # Verify the log file was created and contains the message
        assert log_file.exists()
        with open(log_file, 'r') as f:
            log_content = f.read()
            assert test_message in log_content

def test_logging_context():
    """Test the LoggingContext context manager."""
    logger = logging.getLogger("test_context")
    original_level = logger.level
    
    # Create a test handler
    test_handler = logging.StreamHandler()
    test_handler.setLevel(logging.DEBUG)
    
    # Test with the context manager
    with LoggingContext(logger, level=logging.DEBUG, handler=test_handler):
        assert logger.level == logging.DEBUG
        assert test_handler in logger.handlers
    
    # Verify cleanup
    assert logger.level == original_level
    assert test_handler not in logger.handlers

def test_logging_context_exception_handling():
    """Test that LoggingContext cleans up properly on exceptions."""
    logger = logging.getLogger("test_exception")
    test_handler = logging.StreamHandler()
    
    try:
        with LoggingContext(logger, handler=test_handler):
            assert test_handler in logger.handlers
            raise ValueError("Test exception")
    except ValueError:
        pass
    
    # Handler should be removed even if an exception occurred
    assert test_handler not in logger.handlers

def test_get_logger():
    """Test getting a logger with a specific name."""
    logger_name = "test_get_logger"
    logger = get_logger(logger_name)
    
    assert isinstance(logger, logging.Logger)
    assert logger.name == logger_name
    
    # Verify the logger has the same handlers as the root logger
    root_logger = logging.getLogger()
    assert logger.handlers == root_logger.handlers

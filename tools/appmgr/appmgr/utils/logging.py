"""Logging configuration for the ThreatOS Application Manager."""

import logging
import logging.handlers
import os
import sys
from pathlib import Path
from typing import Optional, Union

# Default log format
DEFAULT_LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
DEFAULT_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# Log levels
LOG_LEVELS = {
    'debug': logging.DEBUG,
    'info': logging.INFO,
    'warning': logging.WARNING,
    'error': logging.ERROR,
    'critical': logging.CRITICAL,
}

def setup_logging(
    level: Union[str, int] = logging.INFO,
    log_file: Optional[Union[str, Path]] = None,
    log_format: str = DEFAULT_LOG_FORMAT,
    date_format: str = DEFAULT_DATE_FORMAT,
    max_bytes: int = 10 * 1024 * 1024,  # 10 MB
    backup_count: int = 5,
) -> None:
    """Configure logging for the application.
    
    Args:
        level: Logging level as string name or level constant.
        log_file: Path to the log file. If None, logs to stderr.
        log_format: Log message format.
        date_format: Date format for log messages.
        max_bytes: Maximum log file size before rotation.
        backup_count: Number of backup log files to keep.
    """
    # Convert string log level to numeric if needed
    if isinstance(level, str):
        level = LOG_LEVELS.get(level.lower(), logging.INFO)
    
    # Create formatter
    formatter = logging.Formatter(fmt=log_format, datefmt=date_format)
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(level)
    
    # Remove existing handlers
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Add console handler
    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
    
    # Add file handler if log file is specified
    if log_file:
        log_file = Path(log_file)
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        file_handler = logging.handlers.RotatingFileHandler(
            filename=log_file,
            maxBytes=max_bytes,
            backupCount=backup_count,
            encoding='utf-8',
        )
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)

def get_logger(name: str) -> logging.Logger:
    """Get a logger with the specified name.
    
    Args:
        name: The name of the logger.
        
    Returns:
        A configured logger instance.
    """
    return logging.getLogger(name)

class LoggingContext:
    """Context manager for temporary logging configuration."""
    
    def __init__(
        self,
        logger: logging.Logger,
        level: Optional[Union[str, int]] = None,
        handler: Optional[logging.Handler] = None,
        close: bool = True
    ):
        self.logger = logger
        self.level = level
        self.handler = handler
        self.close = close
        self.old_level = None
    
    def __enter__(self):
        if self.level is not None:
            self.old_level = self.logger.level
            self.logger.setLevel(self.level)
        
        if self.handler:
            self.logger.addHandler(self.handler)
        
        return self.logger
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.level is not None and self.old_level is not None:
            self.logger.setLevel(self.old_level)
        
        if self.handler:
            self.logger.removeHandler(self.handler)
        
        if self.handler and self.close:
            self.handler.close()
        
        return False

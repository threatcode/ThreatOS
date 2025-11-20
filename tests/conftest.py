"""Pytest configuration and common test fixtures."""
import os
import sys
import pytest
from pathlib import Path

# Add the project root to the Python path
PROJECT_ROOT = str(Path(__file__).parent.parent)
sys.path.insert(0, PROJECT_ROOT)

@pytest.fixture(scope="session")
def project_root():
    """Return the project root directory."""
    return Path(PROJECT_ROOT)

@pytest.fixture(scope="session")
def test_data_dir():
    """Return the path to the test data directory."""
    return Path(__file__).parent / "fixtures"

# Common test markers
def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers",
        "integration: mark test as integration test (dependencies may be required)"
    )
    config.addinivalue_line(
        "markers",
        "slow: mark test as slow-running"
    )

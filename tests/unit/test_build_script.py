"""Unit tests for the build script."""
import os
import subprocess
from pathlib import Path
import pytest

class TestBuildScript:
    """Test cases for the build script."""

    @pytest.mark.parametrize("script_name", ["build-threatos.sh"])
    def test_script_exists(self, project_root, script_name):
        """Verify that the build script exists and is executable."""
        script_path = project_root / script_name
        assert script_path.exists(), f"{script_name} does not exist"
        assert os.access(script_path, os.X_OK), f"{script_name} is not executable"

    @pytest.mark.parametrize("script_name,expected_dir", [
        ("build-threatos.sh", "build-scripts"),
    ])
    def test_script_dependencies_exist(self, project_root, script_name, expected_dir):
        """Verify that required directories and files exist."""
        script_path = project_root / script_name
        
        # Check for build-scripts directory
        build_scripts_dir = project_root / expected_dir
        assert build_scripts_dir.exists() and build_scripts_dir.is_dir(), \
            f"{expected_dir} directory does not exist"

        # Check for required scripts in build-scripts
        required_scripts = ["build.sh", "check-dependencies.sh"]
        for req_script in required_scripts:
            assert (build_scripts_dir / req_script).exists(), \
                f"Required script {req_script} not found in {expected_dir}"

    @pytest.mark.skipif(
        not os.environ.get("CI"),
        reason="Skipping actual build test in non-CI environment"
    )
    def test_dry_run(self, project_root):
        """Test the build script in dry-run mode."""
        try:
            result = subprocess.run(
                ["./build-threatos.sh", "--dry-run"],
                cwd=str(project_root),
                capture_output=True,
                text=True,
                check=False
            )
            assert result.returncode == 0, \
                f"Build script failed with error: {result.stderr}"
        except subprocess.SubprocessError as e:
            pytest.fail(f"Build script execution failed: {e}")

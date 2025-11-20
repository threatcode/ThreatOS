"""Integration tests for the ThreatOS build process."""
import os
import subprocess
import pytest
from pathlib import Path

@pytest.mark.integration
class TestBuildProcess:
    """Integration tests for the build process."""

    @pytest.fixture(autouse=True)
    def setup(self, project_root):
        """Setup test environment."""
        self.project_root = project_root
        self.build_script = project_root / "build-threatos.sh"
        self.build_scripts_dir = project_root / "build-scripts"
        self.installer_dir = project_root / "installer"
        self.iso_artifacts = project_root / "iso-artifacts"

    def test_build_script_help(self):
        """Test that the build script help works."""
        try:
            result = subprocess.run(
                [str(self.build_script), "--help"],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                check=False
            )
            assert result.returncode == 0, \
                f"Build script help failed with error: {result.stderr}"
            assert "Usage:" in result.stdout, "Help output is not as expected"
        except subprocess.SubprocessError as e:
            pytest.fail(f"Build script help execution failed: {e}")

    @pytest.mark.skipif(
        not os.environ.get("CI"),
        reason="Skipping full build test in non-CI environment"
    )
    def test_build_script_dry_run(self):
        """Test the build script in dry-run mode."""
        try:
            # Ensure the build script is executable
            self.build_script.chmod(0o755)
            
            # Run the build script in dry-run mode
            result = subprocess.run(
                [str(self.build_script), "--dry-run"],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                check=False
            )
            
            # Check the result
            assert result.returncode == 0, \
                f"Build script failed with error: {result.stderr}"
            
            # Verify dry-run output
            assert "Running in dry-run mode" in result.stdout, \
                "Dry-run mode not detected in output"
                
        except subprocess.SubprocessError as e:
            pytest.fail(f"Build script execution failed: {e}")

    def test_installer_structure(self):
        """Verify the installer directory structure."""
        # Check required directories
        required_dirs = [
            self.installer_dir / "common",
            self.installer_dir / "config",
            self.installer_dir / "scripts"
        ]
        
        for dir_path in required_dirs:
            assert dir_path.exists() and dir_path.is_dir(), \
                f"Required directory not found: {dir_path}"

    def test_build_scripts_exist(self):
        """Verify that all required build scripts exist."""
        # Check required build scripts
        required_scripts = [
            self.build_scripts_dir / "build.sh",
            self.build_scripts_dir / "check-dependencies.sh",
            self.build_scripts_dir / "fix-hook-extensions.sh"
        ]
        
        for script in required_scripts:
            assert script.exists() and os.access(script, os.X_OK), \
                f"Required build script not found or not executable: {script}"

#!/usr/bin/env python3
"""
GitHub Repository Manager for ThreatOS

A tool to manage GitHub repositories for ThreatOS package development.
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Optional, List, Dict, Any

# Add parent directory to path for shared imports
sys.path.append(str(Path(__file__).parent.parent))
from utils.common import info, success, warn, error

class GitHubRepoManager:
    """Manage GitHub repositories for ThreatOS packages."""
    
    def __init__(self, config_path: Optional[str] = None):
        """Initialize the GitHub repository manager.
        
        Args:
            config_path: Path to the configuration file
        """
        self.config = self._load_config(config_path)
        self.gh_cli = self._check_gh_cli()
    
    def _load_config(self, config_path: Optional[str] = None) -> Dict[str, Any]:
        """Load configuration from file.
        
        Args:
            config_path: Path to the configuration file
            
        Returns:
            Dictionary containing configuration
        """
        default_config = {
            "github": {
                "username": "",
                "token": "",
                "org": "threatcode",
                "base_dir": str(Path.home() / "threatos-repos"),
                "default_branch": "main"
            }
        }
        
        # TODO: Load from config file if provided
        return default_config
    
    def _check_gh_cli(self) -> str:
        """Check if GitHub CLI is installed and authenticated.
        
        Returns:
            Path to the GitHub CLI executable
            
        Raises:
            RuntimeError: If GitHub CLI is not installed or authenticated
        """
        try:
            result = subprocess.run(
                ["gh", "--version"],
                capture_output=True,
                text=True,
                check=True
            )
            gh_path = subprocess.check_output(
                ["which", "gh"],
                text=True
            ).strip()
            
            # Check if authenticated
            auth_check = subprocess.run(
                ["gh", "auth", "status"],
                capture_output=True,
                text=True
            )
            
            if "not logged into any GitHub hosts" in auth_check.stderr:
                warn("GitHub CLI is not authenticated. Please run 'gh auth login'")
            
            return gh_path
            
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            error("GitHub CLI (gh) is not installed or not in PATH")
            error("Please install it from https://cli.github.com/")
            sys.exit(1)
    
    def clone_repo(self, repo: str, dest_dir: Optional[str] = None) -> bool:
        """Clone a GitHub repository.
        
        Args:
            repo: Repository name (e.g., 'threatos/packages')
            dest_dir: Destination directory (default: base_dir/org/repo)
            
        Returns:
            True if successful, False otherwise
        """
        if "/" not in repo:
            repo = f"{self.config['github']['org']}/{repo}"
        
        if not dest_dir:
            repo_name = repo.split('/')[-1]
            dest_dir = os.path.join(
                self.config['github']['base_dir'],
                repo.split('/')[-2],  # org or username
                repo_name
            )
        
        if os.path.exists(dest_dir):
            warn(f"Directory already exists: {dest_dir}")
            return False
        
        try:
            info(f"Cloning {repo} to {dest_dir}")
            subprocess.run(
                ["git", "clone", f"https://github.com/{repo}.git", dest_dir],
                check=True
            )
            success(f"Successfully cloned {repo}")
            return True
            
        except subprocess.CalledProcessError as e:
            error(f"Failed to clone {repo}: {e}")
            return False
    
    def update_repo(self, repo_path: str) -> bool:
        """Update a local Git repository.
        
        Args:
            repo_path: Path to the local repository
            
        Returns:
            True if successful, False otherwise
        """
        if not os.path.isdir(os.path.join(repo_path, ".git")):
            error(f"Not a Git repository: {repo_path}")
            return False
        
        try:
            info(f"Updating repository: {repo_path}")
            subprocess.run(
                ["git", "-C", repo_path, "fetch", "--all"],
                check=True
            )
            subprocess.run(
                ["git", "-C", repo_path, "pull", "--rebase"],
                check=True
            )
            success(f"Successfully updated {repo_path}")
            return True
            
        except subprocess.CalledProcessError as e:
            error(f"Failed to update repository {repo_path}: {e}")
            return False
    
    def create_release(
        self,
        repo_path: str,
        tag: str,
        name: Optional[str] = None,
        notes: Optional[str] = None,
        draft: bool = False,
        prerelease: bool = False
    ) -> bool:
        """Create a GitHub release.
        
        Args:
            repo_path: Path to the local repository
            tag: Release tag (e.g., 'v1.0.0')
            name: Release name (default: same as tag)
            notes: Release notes
            draft: Create as draft
            prerelease: Mark as prerelease
            
        Returns:
            True if successful, False otherwise
        """
        if not os.path.isdir(os.path.join(repo_path, ".git")):
            error(f"Not a Git repository: {repo_path}")
            return False
        
        try:
            # Get the remote URL to determine the repository
            remote_url = subprocess.check_output(
                ["git", "-C", repo_path, "config", "--get", "remote.origin.url"],
                text=True
            ).strip()
            
            # Extract org/repo from the URL
            repo = "/".join(remote_url.rstrip(".git").split("/")[-2:])
            
            # Build the command
            cmd = ["gh", "release", "create", tag]
            
            if name:
                cmd.extend(["--title", name])
            
            if notes:
                if os.path.isfile(notes):
                    cmd.extend(["--notes-file", notes])
                else:
                    cmd.extend(["--notes", notes])
            
            if draft:
                cmd.append("--draft")
            
            if prerelease:
                cmd.append("--prerelease")
            
            # Execute the command
            subprocess.run(cmd, check=True, cwd=repo_path)
            
            success(f"Created release {tag} for {repo}")
            return True
            
        except subprocess.CalledProcessError as e:
            error(f"Failed to create release: {e}")
            return False

def main():
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(description="GitHub Repository Manager for ThreatOS")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Clone command
    clone_parser = subparsers.add_parser("clone", help="Clone a repository")
    clone_parser.add_argument("repo", help="Repository to clone (org/repo or repo)")
    clone_parser.add_argument("-d", "--dest", help="Destination directory")
    
    # Update command
    update_parser = subparsers.add_parser("update", help="Update a local repository")
    update_parser.add_argument("path", help="Path to the local repository")
    
    # Release command
    release_parser = subparsers.add_parser("release", help="Create a release")
    release_parser.add_argument("path", help="Path to the local repository")
    release_parser.add_argument("tag", help="Release tag (e.g., v1.0.0)")
    release_parser.add_argument("--name", help="Release name")
    release_parser.add_argument("--notes", help="Release notes or path to notes file")
    release_parser.add_argument("--draft", action="store_true", help="Create as draft")
    release_parser.add_argument("--prerelease", action="store_true", help="Mark as prerelease")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    manager = GitHubRepoManager()
    
    if args.command == "clone":
        manager.clone_repo(args.repo, args.dest)
    elif args.command == "update":
        manager.update_repo(args.path)
    elif args.command == "release":
        manager.create_release(
            args.path,
            args.tag,
            name=args.name,
            notes=args.notes,
            draft=args.draft,
            prerelease=args.prerelease
        )
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()

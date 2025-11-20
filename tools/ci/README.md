# CI/CD Infrastructure for LXC and autopkgtest

This directory contains the CI/CD configuration for building LXC containers and running autopkgtest in GitHub Actions.

## Workflows

### 1. Build LXC Containers

Location: `.github/workflows/build-lxc-containers.yml`

This workflow builds and pushes an LXC container image to GitHub Container Registry (GHCR).

**Triggered when:**
- Pushes to master branch with changes in LXC configuration
- Manual trigger via workflow_dispatch

**Output:**
- Container image: `ghcr.io/threatcode/ThreatOS/lxc-base:latest`

### 2. Run autopkgtest

Location: `.github/workflows/autopkgtest.yml`

This workflow runs autopkgtest on all .deb packages in the repository using the LXC container.

**Triggered when:**
- New .deb packages are pushed to the repository
- Manual trigger via workflow_dispatch

## Directory Structure

```
tools/ci/
├── lxc/
│   ├── Dockerfile         # LXC container definition
│   └── entrypoint.sh      # Container startup script
└── autopkgtest/          # (Future) autopkgtest configurations
```

## Usage

1. **Build LXC container:**
   - Push changes to the LXC configuration
   - Or manually trigger the workflow from GitHub Actions

2. **Run autopkgtest:**
   - Push .deb packages to the repository
   - Or manually trigger the workflow from GitHub Actions

## Requirements

- GitHub Actions runner with Docker support
- Sufficient permissions to push to GitHub Container Registry (GHCR)
- For local testing: Docker and LXC installed

## Local Testing

To test the LXC container locally:

```bash
# Build the container
cd tools/ci/lxc
docker build -t lxc-base .

# Run the container with necessary privileges
docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d lxc-base
```

# ThreatOS Packaging Tools

A collection of helper scripts to automate and streamline ThreatOS package management, including local repository management and GitHub integration.

## Directory Structure

- `pkg/` - Package management tools
- `repo/` - Local repository management
- `github/` - GitHub integration tools
- `utils/` - Shared utilities
- `config/` - Configuration files

## Quick Start

1. Make sure you have Python 3.8+ and required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Set up your configuration:
   ```bash
   cp config/config.example.ini config/config.ini
   # Edit config.ini with your settings
   ```

3. Run the tools as needed (see individual tool documentation).

## Requirements

- Python 3.8+
- Git
- GitHub CLI (for GitHub integration)
- Various build tools (check individual tool requirements)

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

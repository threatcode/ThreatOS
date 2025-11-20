#!/bin/bash
# ThreatOS Debian Package Builder
# A helper script to build Debian packages for ThreatOS

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "${SCRIPT_DIR}/utils/common.sh"

# Default values
PACKAGE_NAME=""
VERSION="1.0.0"
REVISION="1"
ARCH="amd64"
MAINTAINER="ThreatOS Team <team@threatos.org>"
DESCRIPTION="ThreatOS package"
DEPENDENCIES=""
SECTION="utils"
PRIORITY="optional"
HOMEPAGE="https://threatos.org"

# Build directories
BUILD_DIR="${SCRIPT_DIR}/../../build"
PKG_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}-${REVISION}_${ARCH}"
DEBIAN_DIR="${PKG_DIR}/DEBIAN"

# Create package directory structure
create_package_structure() {
    info "Creating package structure for ${PACKAGE_NAME}"
    
    # Create necessary directories
    mkdir -p "${DEBIAN_DIR}"
    mkdir -p "${PKG_DIR}/usr/local/bin"
    mkdir -p "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}"
    
    # Create control file
    cat > "${DEBIAN_DIR}/control" << EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}-${REVISION}
Section: ${SECTION}
Priority: ${PRIORITY}
Architecture: ${ARCH}
Depends: ${DEPENDENCIES:-bash}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
 ${DESCRIPTION} - Extended description goes here
Homepage: ${HOMEPAGE}
EOF

    # Create postinst script
    cat > "${DEBIAN_DIR}/postinst" << 'EOF'
#!/bin/sh
set -e
# Post-installation script
echo "${PACKAGE_NAME} (${VERSION}) installed successfully!"
# Add any post-installation commands here
exit 0
EOF

    # Create prerm script
    cat > "${DEBIAN_DIR}/prerm" << 'EOF'
#!/bin/sh
set -e
# Pre-removal script
# Add any pre-removal commands here
exit 0
EOF

    # Set executable permissions
    chmod 755 "${DEBIAN_DIR}/postinst"
    chmod 755 "${DEBIAN_DIR}/prerm"
    
    # Create changelog
    cat > "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}/changelog.Debian.gz" << EOF | gzip -9c > "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}/changelog.Debian.gz"
${PACKAGE_NAME} (${VERSION}-${REVISION}) unstable; urgency=medium

  * Initial release for ThreatOS

 -- ${MAINTAINER}  $(date -R)

EOF

    # Create copyright file
    cat > "${PKG_DIR}/usr/share/doc/${PACKAGE_NAME}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${PACKAGE_NAME}
Source: ${HOMEPAGE}

Files: *
Copyright: $(date +%Y) ThreatOS Team
License: GPL-3.0+
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 .
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 .
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 .
 On Debian systems, the complete text of the GNU General
 Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
EOF
}

# Build the package
build_package() {
    info "Building Debian package: ${PACKAGE_NAME}_${VERSION}-${REVISION}_${ARCH}.deb"
    
    # Create package structure
    create_package_structure
    
    # Add your files to the package here
    # Example: cp /path/to/binary "${PKG_DIR}/usr/local/bin/"
    
    # Calculate installed size
    INSTALLED_SIZE=$(du -s --exclude=DEBIAN "${PKG_DIR}" | awk '{print $1}')
    echo "Installed-Size: ${INSTALLED_SIZE}" >> "${DEBIAN_DIR}/control"
    
    # Build the package
    dpkg-deb --build --root-owner-group "${PKG_DIR}" "${BUILD_DIR}/"
    
    # Verify the package
    lintian "${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}-${REVISION}_${ARCH}.deb" || true
    
    success "Package built: ${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}-${REVISION}_${ARCH}.deb"
}

# Clean build directory
clean_build() {
    info "Cleaning build directory..."
    rm -rf "${BUILD_DIR}"
    success "Build directory cleaned"
}

# Show usage information
usage() {
    echo "ThreatOS Debian Package Builder"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -p, --package NAME    Package name (required)"
    echo "  -v, --version VER     Package version (default: 1.0.0)"
    echo "  -r, --revision REV    Package revision (default: 1)"
    echo "  -a, --arch ARCH       Target architecture (default: amd64)"
    echo "  -m, --maintainer NAME Maintainer information (default: ThreatOS Team)"
    echo "  -d, --description DESC Package description"
    echo "  -D, --deps DEPS       Package dependencies (comma-separated)"
    echo "  -c, --clean           Clean build directory before building"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -p threatos-tool -v 1.2.3 -r 2 -d 'ThreatOS Tool'"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--package)
            PACKAGE_NAME="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -r|--revision)
            REVISION="$2"
            shift 2
            ;;
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -m|--maintainer)
            MAINTAINER="$2"
            shift 2
            ;;
        -d|--description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -D|--deps)
            DEPENDENCIES="$2"
            shift 2
            ;;
        -c|--clean)
            clean_build
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "${PACKAGE_NAME}" ]]; then
    error "Package name is required"
    usage
    exit 1
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build the package
build_package

#!/usr/bin/env bash
#
# ThreatOS WSL RootFS Builder
# ===========================
#
# This script builds a Windows Subsystem for Linux (WSL) root filesystem for ThreatOS.
# It supports both native and cross-architecture builds, with options for custom
# package selection and configuration.
#
# Usage:
#   sudo ./build.sh [options]
#
# Options:
#   -a, --arch ARCH      Target architecture (default: amd64, supported: amd64, arm64)
#   -b, --branch BRANCH  Distribution branch (default: master)
#   -d, --desktop DESKTOP
#                       Desktop environment (default: none, options: e17, gnome, i3, kde, lxde, mate, xfce)
#   -m, --mirror URL     Debian mirror URL (default: http://deb.debian.org/debian)
#   -o, --output DIR     Output directory (default: ./output)
#   -t, --toolset TOOLSET
#                       Toolset to install (default: none, options: default, everything, headless, large)
#   -v, --version VER    Version string
#   -h, --help           Show this help message
#
# Environment Variables:
#   ARCH      Same as --arch
#   BRANCH    Same as --branch
#   DESKTOP   Same as --desktop
#   MIRROR    Same as --mirror
#   OUTDIR    Same as --output
#   TOOLSET   Same as --toolset
#   VERSION   Same as --version
#
# Examples:
#   # Basic build with default options
#   sudo ./build.sh
#
#   # Build for ARM64 architecture
#   sudo ./build.sh --arch arm64
#
#   # Build with GNOME desktop
#   sudo ./build.sh --desktop gnome
#
#   # Build with custom mirror
#   sudo MIRROR=http://ftp.debian.org/debian ./build.sh
#
#   # Build with specific version
#   sudo ./build.sh --version 1.0.0

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Exit on error and undefined variables
set -eu

# Load common functions and variables
source "$(dirname "$0")/common.sh"

# Default values
DEFAULT_ARCH=amd64
DEFAULT_BRANCH=master
DEFAULT_DESKTOP=none
DEFAULT_MIRROR=http://deb.debian.org/debian
DEFAULT_TOOLSET=none
DEFAULT_OUTPUT=./output

# Global variables
ARCH=
BRANCH=
DESKTOP=
KEEP=false
MIRROR=
PACKAGES=
TOOLSET=
VERSION=
VARIANT="ThreatOS WSL"
OUTDIR="${DEFAULT_OUTPUT}"
PROMPT="#"

# Known caching proxies
KNOWN_CACHING_PROXIES="\
3142 apt-cacher-ng
8000 squid-deb-proxy"
DETECTED_CACHING_PROXY=

# Supported options
SUPPORTED_ARCHITECTURES="amd64 arm64"
SUPPORTED_BRANCHES="master -rolling -dev -snapshot"
SUPPORTED_DESKTOPS="e17 gnome i3 kde lxde mate xfce none"
SUPPORTED_TOOLSETS="default everything headless large none"

# Default functions
default_toolset() { 
    [ "${DESKTOP:-$DEFAULT_DESKTOP}" = "none" ] && echo "none" || echo "${DEFAULT_TOOLSET}" 
}

default_version() { 
    echo "${BRANCH:-$DEFAULT_BRANCH}" 
}

# Logging functions
vrun() { 
    log_info "Executing: $*"
    "$@"
}

# Helper functions
check_architecture() {
    local arch=$1
    if ! echo "$SUPPORTED_ARCHITECTURES" | grep -q "\b$arch\b"; then
        log_error "Unsupported architecture: $arch"
        log_info "Supported architectures: $SUPPORTED_ARCHITECTURES"
        exit 1
    fi
}

check_desktop() {
    local desktop=$1
    if ! echo "$SUPPORTED_DESKTOPS" | grep -q "\b$desktop\b"; then
        log_error "Unsupported desktop: $desktop"
        log_info "Supported desktops: $SUPPORTED_DESKTOPS"
        exit 1
    fi
}

check_toolset() {
    local toolset=$1
    if ! echo "$SUPPORTED_TOOLSETS" | grep -q "\b$toolset\b"; then
        log_error "Unsupported toolset: $toolset"
        log_info "Supported toolsets: $SUPPORTED_TOOLSETS"
        exit 1
    fi
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -a|--arch)
                ARCH="$2"
                shift 2
                ;;
            -b|--branch)
                BRANCH="$2"
                shift 2
                ;;
            -d|--desktop)
                DESKTOP="$2"
                shift 2
                ;;
            -m|--mirror)
                MIRROR="$2"
                shift 2
                ;;
            -o|--output)
                OUTDIR="$2"
                shift 2
                ;;
            -t|--toolset)
                TOOLSET="$2"
                shift 2
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Set default values if not provided
    ARCH=${ARCH:-$DEFAULT_ARCH}
    BRANCH=${BRANCH:-$DEFAULT_BRANCH}
    DESKTOP=${DESKTOP:-$DEFAULT_DESKTOP}
    MIRROR=${MIRROR:-$DEFAULT_MIRROR}
    TOOLSET=${TOOLSET:-$(default_toolset)}
    OUTDIR=${OUTDIR:-$DEFAULT_OUTPUT}
    VERSION=${VERSION:-$(default_version)}
}

# Show help message
show_help() {
    grep '^# ' "$0" | sed 's/^# //' | sed '1d'
}

# Main function
main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Check for root privileges
    check_root

    # Check dependencies
    check_dependencies

    # Create output directory
    mkdir -p "$OUTDIR"

    # Build the root filesystem
    build_rootfs

    log_success "Build completed successfully!"
    echo "Root filesystem: $OUTDIR/threatos-wsl-$VERSION-$ARCH.tar.gz"
}

# Function to build the root filesystem
build_rootfs() {
    log_info "Starting build for $ARCH architecture..."
    
    # Check if architecture is supported
    check_architecture "$ARCH"
    
    # Check if desktop environment is supported
    check_desktop "$DESKTOP"
    
    # Check if toolset is supported
    check_toolset "$TOOLSET"
    
    # Rest of the build logic will go here
    log_info "Build configuration:"
    log_info "  Architecture: $ARCH"
    log_info "  Branch: $BRANCH"
    log_info "  Desktop: $DESKTOP"
    log_info "  Mirror: $MIRROR"
    log_info "  Toolset: $TOOLSET"
    log_info "  Version: $VERSION"
    log_info "  Output directory: $OUTDIR"
    
    # TODO: Implement the actual build process
    log_warning "Build process not yet implemented"
}

# Run the main function
main "$@"
  local line=
  echo   "┏━━($( b $@ ))"
  while IFS= read -r line; do
    echo "┃ ${line}";
  done
  echo   "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

ask_confirmation() {
  local question=${1:-"Do you want to continue?"}
  local default=yes
  local default_verbing=
  local choices=
  local grand_timeout=60
  local timeout=20
  local time_left=
  local answer=
  local ret=

  ## If stdin is closed, no need to ask, assume yes
  [ -t 0 ] || return 0

  ## Set variables that depend on default
  if [ ${default} = yes ]; then
    default_verbing=proceeding
    choices="[Y/n]"
  else
    default_verbing=aborting
    choices="[y/N]"
  fi

  ## Discard chars pending on stdin
  while read -r -t 0; do read -r; done

  ## Ask the question, allow for X timeouts before proceeding anyway
  grand_timeout=$(( grand_timeout - timeout ))
  for time_left in $( seq ${grand_timeout} -${timeout} 0 ); do
    ret=0
    read -r -t ${timeout} -p "${question} ${choices} " answer \
      || ret=$?
    if [ ${ret} -gt 128 ]; then
      if [ ${time_left} -gt 0 ]; then
        echo "...${time_left} seconds left before ${default_verbing}"
      else
        echo "...No answer, assuming ${default}, ${default_verbing}"
      fi
      continue
    elif [ ${ret} -gt 0 ]; then
      exit ${ret}
    else
      break
    fi
  done

  ## Process the answer
  [ "${answer}" ] && answer=${answer} || answer=${default}
  case "${answer,,}" in
    y|yes) return 0;;
    *)     return 1;;
  esac
  echo ""
}

## check_os
check_os() {
  [ -e "/usr/share/debootstrap/" ] \
    || fail "Can't find debootstrap"

  [ -e "/usr/share/debootstrap/scripts/${BRANCH}" ] \
    || fail "debootstrap has no script for: ${BRANCH}. Need to use a newer debootstrap"

  [ -e "/usr/share/keyrings/${BRANCH}-archive-keyring.gpg" ] \
    || fail "Missing /usr/share/keyrings/${BRANCH}-archive-keyring.gpg"
}

## rootfs_chroot <cmd>
rootfs_chroot() {
  echo "[$( date -u +'%H:%M:%S' )] (chroot) ${VARIANT}:~${PROMPT} $( b "$@" )"
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    chroot "${rootfsDir}" "$@"
}

## debootstrap_log <ret>
debootstrap_log() {
  if [ "${1}" != 0 ]; then
    warn "debootstrap: exit $1"
    [ -e "${rootfsDir}"/debootstrap/debootstrap.log ] && \
      tail -v "${rootfsDir}"/debootstrap/debootstrap.log
    exit "${1}"
  fi
}

## create_rootfs
create_rootfs() {
  export LC_ALL=C
  ## Workaround for https://bugs.launchpad.net/ubuntu/+bug/520465
  export MALLOC_CHECK_=0

  vrun mkdir -pv "${OUTDIR}/"
  rootfsDir="$( mktemp -d )"

  cmd_args=""
  ## If we are using a foreign architecture (e.g. arm64 on amd64) we are opt'ing to do debootstrap in 2 stages
  ## Newer versions of debootstrap may be auto handle this in the future
  if (
       ([ "$( uname -m )" != "aarch64" ] && [ "${ARCH}" == "arm64" ]) ||
       ([ "$( uname -m )" != "x86_64"  ] && [ "${ARCH}" == "amd64" ])
     ); then
    echo "[i] Foreign architecture: $( uname -m ) machine for ${ARCH} rootfs"
    cmd_args="--foreign"
  fi
  ret=0

  ## Install all packages of priority required and important, including apt. Skipping: --variant=minbase
  vrun /usr/sbin/debootstrap \
      ${cmd_args} \
      --arch "${ARCH}" \
      --components=main,contrib,non-free,non-free-firmware \
      --include=${BRANCH}-archive-keyring \
      "${BRANCH}" \
      "${rootfsDir}"/ \
      "${MIRROR}" \
    || debootstrap_log "$?"

#  mount -t proc proc "${rootfsDir}"/proc
#  mount -o bind /dev/ "${rootfsDir}"/dev
#  mount -o bind /dev/pts "${rootfsDir}"/dev/pts

  if (
       ([ "$( uname -m )" != "aarch64" ] && [ "${ARCH}" == "arm64" ]) ||
       ([ "$( uname -m )" != "x86_64"  ] && [ "${ARCH}" == "amd64" ])
     ); then
    if [ "$( uname -m )" != "aarch64" ] && [ "${ARCH}" == "arm64" ]; then
      vrun cp -v /usr/bin/qemu-aarch64-static "${rootfsDir}"/usr/bin
    elif [ "$( uname -m )" != "x86_64" ] && [ "${ARCH}" == "amd64" ]; then
      vrun cp -v /usr/bin/qemu-x86_64-static "${rootfsDir}"/usr/bin
    else
      fail "Unsure of cross-build architecture: $( uname -m ) / ${ARCH}"
    fi
    ret=0
    rootfs_chroot /debootstrap/debootstrap \
        --second-stage \
      || debootstrap_log "$?"
  fi

  echo "[i] Setting shell profile"
  cat << EOF > "${rootfsDir}"/etc/profile
# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

# WSL already sets PATH, shouldn't be overridden
IS_WSL=\$( grep -i microsoft /proc/version )
if test "\${IS_WSL}" = ""; then
  if [ "\$( id -u )" -eq 0 ]; then
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  else
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
  fi
fi
export PATH

if [ "$\{PS1-}" ]; then
  if [ "\${BASH-}" ] && [ "\${BASH}" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "\$( id -u )" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r \$i ]; then
      . \$i
    fi
  done
  unset i
fi
EOF

 #rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes install ${BRANCH}-defaults # Skipping: --no-install-recommends
  rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes install ${BRANCH}-wsl

  [ "${TOOLSET}" != "none" ] && \
    rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes install ${BRANCH}-${TOOLSET}
  [ "${DESKTOP}" != "none" ] && \
    rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes install ${BRANCH}-desktop-${DESKTOP} xorg xrdp
  [ "${PACKAGES}" ] && \
    rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes install ${PACKAGES}

  if [ "${DESKTOP}" != "none" ]; then
    echo "[i] Switching xrdp to use 3390/TCP"
    vrun sed -i 's/port=3389/port=3390/g' "${rootfsDir}"/etc/xrdp/xrdp.ini
  fi

  ## Using pipes with vrun doesn't work too well
  #echo "deb ${DEFAULT_MIRROR} ${BRANCH} main contrib non-free non-free-firmware" > "${rootfsDir}"/etc/apt/sources.list
  cat << EOF > "${rootfsDir}"/etc/apt/sources.list
deb ${DEFAULT_MIRROR} ${BRANCH} main contrib non-free non-free-firmware
EOF
  echo "threatos" > "${rootfsDir}"/etc/hostname
  #echo "127.0.0.1 localhost" > "${rootfsDir}"/etc/hosts
  cat << EOF > "${rootfsDir}"/etc/hosts
127.0.0.1 localhost
::1   localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
EOF
  vrun truncate -s 0 "${rootfsDir}"/etc/resolv.conf

  ## Add wsl.conf and enable systemd
  vrun cp -v extra-files/wsl.conf "${rootfsDir}"/etc/wsl.conf
  chown root:root "${rootfsDir}"/etc/wsl.conf
  chmod 0644      "${rootfsDir}"/etc/wsl.conf

  ## Add wsl-distribution and set out of box experience command, default uid, and a default name
  vrun cp -v extra-files/wsl-distribution.conf "${rootfsDir}"/etc/wsl-distribution.conf
  chown root:root "${rootfsDir}"/etc/wsl-distribution.conf
  chmod 0644      "${rootfsDir}"/etc/wsl-distribution.conf

  ## Add threatos.ico for wsl-distribution to reference
  mkdir -pv "${rootfsDir}"/usr/lib/wsl/
  vrun cp -v extra-files/threatos-wsl.ico "${rootfsDir}"/usr/lib/wsl/threatos-wsl.ico
  chown root:root "${rootfsDir}"/usr/lib/wsl/threatos-wsl.ico
  chmod 0644      "${rootfsDir}"/usr/lib/wsl/threatos-wsl.ico

  ## Create out of box experience script, enable new user creation and create text file in usr/local/share
  vrun cp -v extra-files/wsl-oobe "${rootfsDir}"/usr/lib/wsl/wsl-oobe

  ## Make script executable
  rootfs_chroot chmod 0755 /usr/lib/wsl/wsl-oobe

  ## Clean - APT packages
  rootfs_chroot env DEBIAN_FRONTEND=noninteractive apt-get --quiet --yes clean
  vrun rm -vrf "${rootfsDir}"/var/lib/apt/lists/*
  vrun mkdir -vp "${rootfsDir}"/var/lib/apt/lists/partial
  ## Clean - Logs
  ! "${KEEP}" && \
    vrun find "${rootfsDir}"/var/log -depth -type f -exec truncate -s 0 {} +
  ## Clean - qemu
  (
    ([ "$( uname -m )" != "aarch64" ] && [ "${ARCH}" == "arm64" ]) ||
    ([ "$( uname -m )" != "x86_64"  ] && [ "${ARCH}" == "amd64" ])
  ) && \
     vrun rm -vf "${rootfsDir}"/usr/bin/qemu*
  ## Clean - Misc
  vrun rm -vf "${rootfsDir}"/var/cache/ldconfig/aux-cache

  ## Clean - Systemd
  rootfs_chroot env DEBIAN_FRONTEND=noninteractive systemctl mask systemd-resolved.service systemd-networkd.service NetworkManager.service systemd-tmpfiles-setup.service systemd-tmpfiles-clean.service systemd-tmpfiles-clean.timer systemd-tmpfiles-setup-dev-early.service systemd-tmpfiles-setup-dev.service tmp.mount

  #umount "${rootfsDir}"/dev/pts
  #sleep 10
  #umount "${rootfsDir}"/dev
  #sleep 10
  #umount "${rootfsDir}"/proc
  #sleep 10

  vrun pushd "${rootfsDir}/"
  ## Skipping tar -v: too noisy
  ## Skipping tar -C "${rootfsDir}"/ / --exclude=./: Due './' being added (tar -tvfj output/*tar.gz | sort -k 9 | head)
  vrun tar --ignore-failed-read --xattrs -czf "${OUTDIR}/${OUTPUT}.tar.gz" ./"*"
  vrun popd

  if ! "${KEEP}"; then
    ## Skipping rm -v - too noisy
    vrun rm -rf "${rootfsDir}"/
  fi
}

USAGE="Usage: $( basename $0 ) <options>

Build a Debian-based Linux ${VARIANT} rootfs

Build options:
  -a ARCH     Build an rootfs for this architecture, default: $( b ${DEFAULT_ARCH} )
              Supported values: ${SUPPORTED_ARCHITECTURES}
  -b BRANCH   Debian branch used to build the rootfs, default: $( b ${DEFAULT_BRANCH} )
              Supported values: ${SUPPORTED_BRANCHES}
  -k          Keep intermediary build artifacts
  -m MIRROR   Mirror used to build the rootfs, default: $( b ${DEFAULT_MIRROR} )
  -x VERSION  What to name the rootfs release as, default: $( b $( default_version ) )

Customization options:
  -D DESKTOP  Desktop environment installed in the rootfs, default: $( b ${DEFAULT_DESKTOP} )
              Supported values: ${SUPPORTED_DESKTOPS}
  -P PACKAGES Install extra packages (comma/space separated list)
  -T TOOLSET  The selection of tools to include in the rootfs, default: $( b $( default_toolset ) )
              Supported values: ${SUPPORTED_TOOLSETS}

Supported environment variables:
  http_proxy  HTTP proxy URL, refer to the README.md for more details

Refer to the README.md for examples"

while getopts ":a:b:D:f:hkL:m:P:r:s:T:U:v:x:zZ:" opt; do
  case ${opt} in
    (a) ARCH=${OPTARG};;
    (b) BRANCH=${OPTARG};;
    (D) DESKTOP=${OPTARG};;
    (h) echo "${USAGE}"; exit 0;;
    (k) KEEP=true;;
    (m) MIRROR=${OPTARG};;
    (P) PACKAGES="${PACKAGES} ${OPTARG}";;
    (T) TOOLSET=${OPTARG};;
    (x) VERSION=${OPTARG};;
    (*) echo "${USAGE}" 1>&2; exit 1;;
  esac
done
shift $((OPTIND - 1))

## If there isn't any variables setup, use default
[ "${ARCH}"    ] || ARCH=${DEFAULT_ARCH}
[ "${BRANCH}"  ] || BRANCH=${DEFAULT_BRANCH}
[ "${DESKTOP}" ] || DESKTOP=${DEFAULT_DESKTOP}
[ "${MIRROR}"  ] || MIRROR=${DEFAULT_MIRROR}
[ "${TOOLSET}" ] || TOOLSET=$( default_toolset )
[ "${VERSION}" ] || VERSION=$( default_version )

TOOLSET="$( echo ${TOOLSET} | sed 's/debian-//' )"

case $( echo ${ARCH}| tr '[:upper:]' '[:lower:]' ) in
  x64|x86_64|x86-64|amd64)
    ARCH=amd64
    ;;
  arm64|aarch64)
    ARCH=arm64
    ;;
esac

case ${BRANCH} in
  master|rolling|dev|snapshot)
    BRANCH=${BRANCH}
    ;;
esac

## Order packages alphabetically, separate each package with ", "
PACKAGES=$( echo ${PACKAGES} | sed "s/[, ]\+/\n/g" | LC_ALL=C sort -u \
  | awk '{ printf "%s ", $0 }' | sed "s/[[:space:]]*$//" | sed "s/[, ]*$//" )

## Filename structure for final file
OUTPUT=$( echo "debian-${VERSION}-${VARIANT}-rootfs-${ARCH}" | tr '[:upper:]' '[:lower:]' )

## Validate some options
echo "${SUPPORTED_BRANCHES}" | grep -qw "${BRANCH}" \
  || fail "Unsupported branch: ${BRANCH}"
echo "${SUPPORTED_DESKTOPS}" | grep -qw "${DESKTOP}" \
  || fail "Unsupported desktop: ${DESKTOP}"
echo "${SUPPORTED_TOOLSETS}" | grep -qw "${TOOLSET}" \
  || fail "Unsupported toolset: ${TOOLSET}"
echo "${SUPPORTED_ARCHITECTURES}" | grep -qw "${ARCH}" \
  || fail "Unsupported architecture: ${ARCH}"

## Check environment variables for http_proxy
## [ -v ... ] isn't supported on all every bash version
if ! [ $( env | grep http_proxy ) ]; then
  ## Attempt to detect well-known http caching proxies on localhost,
  ## cf. bash(1) section "REDIRECTION". This is not bullet-proof.
  while read port proxy; do
    (</dev/tcp/localhost/${port}) 2>/dev/null || continue
    DETECTED_CACHING_PROXY="${port} ${proxy}"
## Docker: host.docker.internal TODO
    export http_proxy="http://127.0.0.1:${port}"
    break
  done <<< "${KNOWN_CACHING_PROXIES}"
fi

check_os

if [ $( id -u ) -ne 0 ]; then
  PROMPT=$
  warn "This script requires certain privileges"
  warn "Please consider running it using the root user"
  echo ""
fi

## Print a summary
{
echo "# Proxy configuration:"
if [ "${DETECTED_CACHING_PROXY}" ]; then
  read port proxy <<< ${DETECTED_CACHING_PROXY}
  echo " * Detected caching proxy $( b ${proxy} ) on port $( b ${port} )"
elif [ "${http_proxy:-}" ]; then
  echo " * Using proxy via environment variable: $( b http_proxy=${http_proxy} )"
else
  echo " * $( b No HTTP proxy ) configured, all packages will be downloaded from the Internet"
fi

echo "# ${VARIANT} rootfs output:"
echo " * Build a Debian-based Linux ${VARIANT} rootfs for $( b ${ARCH} ) architecture"
echo "# Build options:"
[ "${MIRROR}"   ] && echo " * Build mirror: $( b ${MIRROR} )"
[ "${BRANCH}"   ] && echo " * Branch: $( b ${BRANCH} )"
[ "${VERSION}"  ] && echo " * Version: $( b ${VERSION} )"
[ "${DESKTOP}"  ] && echo " * Desktop environment: $( b ${DESKTOP} )"
[ "${TOOLSET}"  ] && echo " * Tool selection: $( b ${TOOLSET} )"
[ "${PACKAGES}" ] && echo " * Additional packages: $( b ${PACKAGES} )"
  "${KEEP}"       && echo " * Keep temporary files: $( b ${KEEP} )"
} | message "Debian-based Linux ${VARIANT} rootfs"

## Ask for confirmation before starting the build
ask_confirmation || { echo "Abort"; exit 1; }

## Build
create_rootfs

## Finish
cat << EOF
..............
            ..,;:ccc,.
          ......''';lxO.
.....''''..........,:ld;
           .';;;:::;,,.x,
      ..'''.            0Xxoc:,.  ...
  ....                ,ONkc;,;cokOdc',.
 .                   OMo           ':$( b dd )o.
                    dMc               :OO;
                    0M.                 .:o.
                    ;Wd
                     ;XO,
                       ,d0Odlc;,..
                           ..',;:cdOOd::,.
                                    .:d;.':;.
                                       'd,  .'
                                         ;l   ..
                                          .o
                                            c
                                            .'
                                             .
Successful build! The following build artifacts were produced:
EOF
## /recipes/ is due to container volume mount
find "${OUTDIR}/" -maxdepth 1 -type f -name "${OUTPUT}*" | sed 's_^/recipes/__;
                                                                s_^_* _'

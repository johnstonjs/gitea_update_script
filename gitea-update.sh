#!/bin/sh
# A shell script to automatically update Gitea
# Depends only on basic shell utilities (curl, cut, find, grep, sed, wget)
# Assumes use of systemd for Gitea start/stop


DIR=/usr/local/bin/gitea    # Set location of gitea binary on local system
ARCH=linux-amd64            # Set architecture type:
                            # darwin-10.6.386 darwin-10.6-amd64 linux-386
                            # linux-arm-5,6,7,arm64,mips,mips64,mips64le
USER=root                   # User for file permissions on Gitea binary
GROUP=git                   # Group for file permissions on Gitea binary
INIT_TYPE=systemd           # Specify init script type (only systemd now)
PRUNE=1                     # If TRUE, script will delete older versions
DEBUG=1                     # If TRUE, debug messages are printed to STDOUT

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                                  # Pluck JSON value
    cut -c 2-                                                       # Remove the leading "v"
# Usage
# $ get_latest_release "creationix/nvm"
# 0.31.4
# Adapted from:
# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
}

get_current_version() {
  eval $1 -v | cut -d " " -f 3
}

# Set variable #new_ver by checking release status from GitHub
NEW_VER=$(get_latest_release "go-gitea/gitea")
NEW_VER=1.8.2
if [ $DEBUG -eq 1 ]; then
  echo "New Version:    $NEW_VER"
fi

# Check if gitea binary exists at specified $FILE
if test -f "$DIR/gitea"; then
  if [ $DEBUG -eq 1 ]; then
    echo "$DIR/gitea exists"
  fi
else
  echo "ERROR: $DIR/gitea does not exist"
  exit 1
fi

# Check current version
CUR_VER=$(get_current_version $DIR/gitea)

if [ $DEBUG -eq 1 ]; then
  echo "Current Version: $CUR_VER"
fi

if [ $NEW_VER != $CUR_VER ]; then
  if [ $DEBUG -eq 1 ]; then
    echo "There is a newer release available, downloading..."
  fi
  # Download the latest version of Gitea binary
  wget -N https://github.com/go-gitea/gitea/releases/download/v$NEW_VER/gitea-$NEW_VER-$ARCH -P $DIR/bin/
  # Set USER/GROUP ownership for new Gitea binary
  chown $USER:$GROUP $DIR/bin/gitea-$NEW_VER-$ARCH
  # Set permissions for new Gitea binary (rwxr-x---)
  chmod 0750 $DIR/bin/gitea-$NEW_VER-$ARCH
  # Stop the Gitea service
  case $INIT_TYPE in
    systemd)
      service gitea stop
      ;;
    *)
  esac
  # Update the symlink at $DIR/gitea to pint to latest Gitea binary
  ln -sf $DIR/bin/gitea-$NEW_VER-$ARCH $DIR/gitea
  # Start the Gitea service
  service gitea start
  if [ PRUNE -eq 1 ]; then
    find $DIR/bin/ -type f ! -newer gitea-$NEW_VER-$ARCH ! -name gitea-$NEW_VER-$ARCH -delete
  fi
else
  if [ $DEBUG -eq 1 ]; then
    echo "The latest version is already installed"
    exit 1
  fi
fi

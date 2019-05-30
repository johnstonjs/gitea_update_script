#/bin/sh

# Set location of gitea binary on local system
DIR=/usr/local/bin/gitea
#FILE=/usr/local/bin/gitea/gitea
# Set architecture type:
  # darwin-10.6.386 darwin-10.6-amd64 linux-386
  # linux-arm-5,6,7,arm64,mips,mips64,mips64le
ARCH=linux-amd64

DEBUG=1

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
new_ver=$(get_latest_release "go-gitea/gitea")

if [ $DEBUG -eq 1 ]; then
  echo "New Version:    $new_ver"
fi

# Check if gitea binary exists at specified $FILE
if test -f "$DIR/gitea"; then
  if [ $DEBUG -eq 1 ]; then
    echo "$FILE exists"
  fi
else
  echo "ERROR: $FILE does not exist"
  exit 1
fi

# Check current version
cur_ver=$(get_current_version $FILE)

if [ $DEBUG -eq 1 ]; then
  echo "Current Version: $cur_ver"
fi

if [ $new_ver != $cur_ver ]; then
  if [ $DEBUG -eq 1 ]; then
    echo "There is a newer release available, downloading..."
  fi
  #wget -N https://dl.gitea.io/gitea/$VERSION/gitea-$VERSION-$ARCH -P $DIR/bin/

else
  if [ $DEBUG -eq 1 ]; then
    echo "The latest version is already installed"
    exit 1
  fi
fi

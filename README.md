# gitea_update_script

A script to automatically update [Gitea](https://gitea.io) installed on local
host to the latest version from Github.

## Installation

Place in an appropriate location on local host and execute on schedule via cron.

## Dependencies

Requires some basic shell commands listed in the script, and assumes that
`systemd` is used to start/stop Gitea.

Assumes that Gitea is executed from a symlink specified in $DIR.  The actual
Gitea binaries are placed in $DIR/bin.  This script will automatically update
the symlink when a new verson is downloaded.

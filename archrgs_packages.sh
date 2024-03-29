#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

__version="1.8.5-BETA"

[[ "$__debug" -eq 1 ]] && set -x

##Archrgs Install Location
rootdir="/opt/archrgs"

##If __user Is Set Install For That User, Else Use sudo_user
if [[ -n "$__user" ]]; then
  user="$__user"
  if ! id -u "$__user" &>/dev/null; then
    echo "User $__user not exist"
    exit 1
  fi
else
  user="$SUDO_USER"
  [[ -z "$user" ]] && user="$(id -un)"
fi

home="$(eval echo ~$user)"
datadir="$home/Arch-RGS"
biosdir="$datadir/bios"
romdir="$datadir/roms"
emudir="$rootdir/emulators"
configdir="$rootdir/configs"

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

__logdir="$scriptdir/logs"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"

pkgdir="$scriptdir/packages"

##Check If Sudo Is Used
if [[ "$(id -u)" -ne 0 ]]; then
  echo "Script must be run under sudo from the user you want to install for. Try 'sudo $0'"
  exit 1
fi

__backtitle="Arch-RGS Setup. Installation folder: $rootdir for user $user"

source "$scriptdir/scriptmodules/system.sh"
source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/inifuncs.sh"
source "$scriptdir/scriptmodules/packages.sh"

setup_env

archrgs_registerAllModules

archrgs_ret=0
if [[ $# -gt 0 ]]; then
  setupDirectories
  archrgs_callModule "$@"
  archrgs_ret="$?"
else
  archrgs_printUsageinfo
fi

if [[ "${#__ERRMSGS[@]}" -gt 0 ]]; then
  ##Override Return Code If Errmsgs Is Set
  [[ "$rgs_ret" -eq 0 ]] && rgs_ret=1
  printMsgs "console" "Errors:\n${__ERRMSGS[@]}"
fi

if [[ "${#__INFMSGS[@]}" -gt 0 ]]; then
  printMsgs "console" "Info:\n${__INFMSGS[@]}"
fi

exit $rgs_ret


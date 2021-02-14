#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

__archive_url="https://files.retropie.org.uk/archives"

function setup_env() {
  __ERRMSGS=()
  __INFMSGS=()

  ##CHECK FOR PACMAN COMMAND
  [[ -z "$(command -v pacman)" ]] && fatalError "Unsupported OS - No pacman command found."

  test_chroot

  get_platform
  get_os_version
  get_archrgs_depends

  if [[ -z "$__nodialog" ]]; then
    __nodialog=0
  fi
}

function test_chroot() {
  ##TEST IF WE ARE IN A CHROOT
  if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]; then
    [[ -z "$QEMU_CPU" && -n "$__qemu_cpu" ]] && export QEMU_CPU=$__qemu_cpu
    __chroot=1
  ##DETECT THE USAGE OF SYSTEMD-NSPAWN
  elif [[ -n "$(systemd-detect-virt)" && "$(systemd-detect-virt)" == "systemd-nspawn" ]]; then
    __chroot=1
  else
    __chroot=0
  fi
}

function get_os_version() {
  getDepends lsb-release

  ##GET OS DISTRIBUTOR ID, DESCRIPTION & RELEASE
  __os_desc=$(lsb_release -s -i -d -r)
}

function get_archrgs_depends() {
  local depends=(
    base-devel
    dialog
    git
    perl-rename
    python
    python-six
    python-pyudev
    unzip
    wget
    xmlstarlet
  )
  [[ -n "$DISTCC_HOSTS" ]] && depends+=(distcc)

  if ! getDepends "${depends[@]}"; then
    fatalError "Unable to install packages required by $0 - ${md_ret_errors[@]}"
  fi
}

function get_platform() {
  local architecture
  architecture="$(uname --machine)"

  if [[ -z "$__platform" ]]; then
    case "$(sed -n '/^Hardware/s/^.*: \(.*\)/\1/p' </proc/cpuinfo)" in
    *)
      case $architecture in
      x86_64|amd64)
        __platform="x86_64"
        ;;
      esac
      ;;
    esac
  fi

  if [[ "$__platform" != "x86_64" ]]; then
    fatalError "Unknown platform - please manually set the __platform variable to one of the following: x86_64"
  fi
}

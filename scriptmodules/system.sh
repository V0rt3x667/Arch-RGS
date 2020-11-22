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

  conf_memory_vars
  #conf_build_vars (SEE NOTE ON FUNCTION BELOW)

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

function conf_memory_vars() {
  __memory_total_kb=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
  __memory_total=$((__memory_total_kb / 1024))
  if grep -q "^MemAvailable:" /proc/meminfo; then
    __memory_avail_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
  else
    local mem_free=$(awk '/^MemFree:/{print $2}' /proc/meminfo)
    local mem_cached=$(awk '/^Cached:/{print $2}' /proc/meminfo)
    local mem_buffers=$(awk '/^Buffers:/{print $2}' /proc/meminfo)
    __memory_avail_kb=$((mem_free + mem_cached + mem_buffers))
  fi
  __memory_avail=$((__memory_avail_kb / 1024))
}

##MARKED FOR REMOVAL
##NOT CURRENTLY USED AS PKGBUILD USES BUILD FLAGS IN makepkg.conf
function conf_build_vars() {
  __gcc_version=$(gcc -dumpversion)

  # calculate build concurrency based on cores and available memory
  __jobs=1
  local unit=768
  if [[ "$(nproc)" -gt 1 ]]; then
    local nproc="$(nproc)"
    # max one thread per unit (MB) of ram
    local max_jobs=$(($__memory_avail / $unit))
    if [[ "$max_jobs" -gt 0 ]]; then
      if [[ "$max_jobs" -lt "$nproc" ]]; then
        __jobs="$max_jobs"
      else
        __jobs="$nproc"
      fi
    fi
  fi
  __default_makeflags="-j${__jobs}"

  # set our default gcc optimisation level
  if [[ -z "$__opt_flags" ]]; then
    __opt_flags="$__default_opt_flags"
  fi

  # set default cpu flags
  [[ -z "$__cpu_flags" ]] && __cpu_flags="$__default_cpu_flags"

  # if default cxxflags is empty, use our default cflags
  [[ -z "$__default_cxxflags" ]] && __default_cxx_flags="$__default_cflags"

  # add our cpu and optimisation flags
  __default_cflags+=" $__cpu_flags $__opt_flags"
  __default_cxxflags+=" $__cpu_flags $__opt_flags"

  # if not overridden by user, configure our compiler flags
  [[ -z "$__cflags" ]] && __cflags="$__default_cflags"
  [[ -z "$__cxxflags" ]] && __cxxflags="$__default_cxxflags"
  [[ -z "$__asflags" ]] && __asflags="$__default_asflags"
  [[ -z "$__makeflags" ]] && __makeflags="$__default_makeflags"

  # export our compiler flags so all child processes can see them
  export CFLAGS="$__cflags"
  export CXXFLAGS="$__cxxflags"
  export ASFLAGS="$__asflags"
  export MAKEFLAGS="$__makeflags"

  # if using distcc, add /usr/lib/distcc to PATH/MAKEFLAGS
  if [[ -n "$DISTCC_HOSTS" ]]; then
    PATH="/usr/lib/distcc:$PATH"
    MAKEFLAGS+=" PATH=$PATH"
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

  #set_platform_defaults (SEE NOTE ON FUNCTION BELOW)
  platform_${__platform}
}

##MARKED FOR REMOVAL
##NOT CURRENTLY USED AS PKGBUILD USES BUILD FLAGS IN makepkg.conf
function set_platform_defaults() {
  __default_opt_flags="-O2"
}
##MARKED FOR REMOVAL
##NOT CURRENTLY USED AS PKGBUILD USES BUILD FLAGS IN makepkg.conf
function platform_x86_64() {
  __default_cpu_flags="-march=native -mtune=native"
  __platform_flags="x86_64"
}


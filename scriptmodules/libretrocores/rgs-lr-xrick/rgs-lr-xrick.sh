#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-xrick"
archrgs_module_desc="Rick Dangerous Libretro Core"
archrgs_module_licence="CUSTOM https://raw.githubusercontent.com/libretro/xrick-libretro/master/README"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-xrick() {
  pacmanPkg rgs-lr-xrick
}

function remove_rgs-lr-xrick() {
  pacmanRemove rgs-lr-xrick
}

function configure_rgs-lr-xrick() {
  setConfigRoot "ports"

  addPort "$md_id" "xrick" "XRick" "$md_inst/xrick_libretro.so"

  [[ "$md_mode" == "remove" ]] && return

  ensureSystemretroconfig "ports/xrick"
  cp "$md_inst/data/data.zip" "$biosdir/"
}


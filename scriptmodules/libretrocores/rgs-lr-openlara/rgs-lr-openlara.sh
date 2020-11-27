#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-openlara"
archrgs_module_desc="Tomb Raider Libretro Core"
archrgs_module_help="ROM Extensions: .phd .psx .tr2\n\nPlease copy your Tomb Raider data files to $romdir/ports/tombraider before running the game."
archrgs_module_licence="BSD https://raw.githubusercontent.com/libretro/OpenLara/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-openlara() {
  pacmanPkg rgs-lr-openlara
}

function remove_rgs-lr-openlara() {
  pacmanRemove rgs-lr-openlara
}

function configure_rgs-lr-openlara() {
  setConfigRoot "ports"

  mkRomDir "tomb_raider"

  addPort "$md_id" "tomb_raider" "$md_inst/openlara_libretro.so"

  [[ "$md_mode" == "remove" ]] && return

  ensureSystemretroconfig "tomb_raider"
}


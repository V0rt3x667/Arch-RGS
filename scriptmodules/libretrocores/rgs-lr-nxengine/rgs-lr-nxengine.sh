#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-nxengine"
archrgs_module_desc="NxEngine (Cave Story Engine) Libretro Core"
archrgs_module_help="Copy the original Cave Story game files to $romdir/ports/CaveStory so you have the file $romdir/ports/CaveStory/Doukutsu.exe present."
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/nxengine-libretro/master/nxengine/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-nxengine() {
  pacmanPkg rgs-lr-nxengine
}

function remove_rgs-lr-nxengine() {
  pacmanRemove rgs-lr-nxengine
}

function configure_rgs-lr-nxengine() {
  mkRomDir "ports/cavestory"

  setConfigRoot "ports"

  addPort "$md_id" "cavestory" "Cave Story" "$md_inst/nxengine_libretro.so" "$romdir/ports/cavestory/Doukutsu.exe"

  ensureSystemretroconfig "ports/cavestory"
}


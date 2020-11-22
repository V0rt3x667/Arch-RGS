#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-craft"
archrgs_module_desc="Craft (MineCraft Clone) Libretro Core"
archrgs_module_help="ROM Extensions: n/a"
archrgs_module_licence="MIT https://raw.githubusercontent.com/libretro/Craft/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-craft() {
  pacmanPkg rgs-lr-craft
}

function remove_rgs-lr-craft() {
  pacmanRemove rgs-lr-craft
}

function configure_rgs-lr-craft() {
  setConfigRoot "ports"

  addPort "$md_id" "craft" "Craft" "$md_inst/craft_libretro.so"

  mkRomDir "ports/craft"

  ensureSystemretroconfig "ports/craft"
}


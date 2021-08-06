#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-mgba"
archrgs_module_desc="Nintendo Game Boy, Game Boy Advance & Game Boy Color Libretro Core"
archrgs_module_help="ROM Extensions: .gb .gbc .gba .zip\n\nCopy Your Game Boy ROMs to $romdir/gb\nGame Boy Color ROMs to $romdir/gbc\nGame Boy Advance ROMs to $romdir/gba\n\nCopy the recommended BIOS files gb_bios.bin, gbc_bios.bin, sgb_bios.bin and gba_bios.bin to $biosdir"
archrgs_module_licence="MPL2 https://raw.githubusercontent.com/libretro/mgba/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-mgba() {
  pacmanPkg rgs-lr-mgba
}

function remove_rgs-lr-mgba() {
  pacmanRemove rgs-lr-mgba
}

function configure_rgs-lr-mgba() {
  local system
  local def
  
  for system in gb gbc gba; do
    def=0
    [[ "$system" == "gba" ]] && def=1
    mkRomDir "$system"
    ensureSystemretroconfig "$system"
    addEmulator "$def" "$md_id" "$system" "$md_inst/mgba_libretro.so"
    addSystem "$system"
  done
}


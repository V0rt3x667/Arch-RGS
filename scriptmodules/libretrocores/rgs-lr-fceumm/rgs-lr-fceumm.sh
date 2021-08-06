#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-fceumm"
archrgs_module_desc="Nintendo NES & Famicom Libretro Core"
archrgs_module_help="ROM Extensions: .nes .zip\n\nCopy Your NES ROMs to $romdir/nes\n\nFor the Famicom Disk System copy your ROMs to $romdir/fds\n\nFor the Famicom Disk System copy the required BIOS file disksys.rom to $biosdir"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-fceumm/master/Copying"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-fceumm() {
  pacmanPkg rgs-lr-fceumm
}

function remove_rgs-lr-fceumm() {
  pacmanRemove rgs-lr-fceumm
}

function configure_rgs-lr-fceumm() {
  mkRomDir "nes"
  mkRomDir "fds"

  ensureSystemretroconfig "nes"
  ensureSystemretroconfig "fds"

  addEmulator 1 "$md_id" "nes" "$md_inst/fceumm_libretro.so"
  addEmulator 1 "$md_id" "fds" "$md_inst/fceumm_libretro.so"

  addSystem "nes"
  addSystem "fds"
}


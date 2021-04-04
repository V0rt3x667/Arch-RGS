#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-dosbox-pure"
archrgs_module_desc="MS-DOS Libretro Core"
archrgs_module_help="ROM Extensions: .bat .com .cue .dosz .exe .ins .ima .img .iso .m3u .m3u8 .vhd .zip\n\nCopy your DOS games to $ROMDIR/pc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dosbox-pure/main/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-dosbox-pure() {
  pacmanPkg rgs-lr-dosbox-pure
}

function remove_rgs-lr-dosbox-pure() {
  pacmanRemove rgs-lr-dosbox-pure
}

function configure_rgs-lr-dosbox-pure() {
  mkRomDir "pc"
  ensureSystemretroconfig "pc"

  addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_pure_libretro.so"
  addSystem "pc"
}


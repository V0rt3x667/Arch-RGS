#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-vice"
archrgs_module_desc="Commodore C64 & VIC 20 Libretro Core"
archrgs_module_help="ROM Extensions: .crt .d64 .g64 .prg .t64 .tap .x64 .zip .vsf\n\nCopy Your Commodore 64 Games to $romdir/c64"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vice-libretro/master/vice/COPYING"
archrgs_module_section="libretrocores"
archrgs_module_flags="x86_64"

function install_bin_rgs-lr-vice() {
  pacmanPkg rgs-lr-vice
}

function remove_rgs-lr-vice() {
  pacmanRemove rgs-lr-vice
}

function configure_rgs-lr-vice() {
  mkRomDir "c64"

  ensureSystemretroconfig "c64"

  [[ "$md_mode" == "remove" ]] && return

  cp -R "$md_inst/data" "$biosdir"
  chown -R $user:$user "$biosdir/data"

  addEmulator 1 "$md_id" "c64" "$md_inst/vice_x64_libretro.so"
  addSystem "c64"
}


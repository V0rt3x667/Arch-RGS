#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-parallel-n64"
archrgs_module_desc="Nintendo N64 Libretro Core"
archrgs_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy Your N64 ROMs to $romdir/n64"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/parallel-n64/master/mupen64plus-core/LICENSES"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-parallel-n64() {
  pacmanPkg rgs-lr-parallel-n64
}

function remove_rgs-lr-parallel-n64() {
  pacmanRemove rgs-lr-parallel-n64
}

function configure_rgs-lr-parallel-n64() {
  mkRomDir "n64"

  ensureSystemretroconfig "n64"

  setRetroArchCoreOption "parallel-n64-gfxplugin" "auto"
  setRetroArchCoreOption "parallel-n64-gfxplugin-accuracy" "high"
  setRetroArchCoreOption "parallel-n64-screensize" "640x480"

  addEmulator 0 "$md_id" "n64" "$md_inst/parallel_n64_libretro.so"
  addSystem "n64"
}


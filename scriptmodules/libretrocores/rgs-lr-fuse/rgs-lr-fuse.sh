#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-fuse"
archrgs_module_desc="Sinclair ZX Spectrum Libretro Core"
archrgs_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/fuse-libretro/master/LICENSE"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-fuse() {
  pacmanPkg rgs-lr-fuse
}

function remove_rgs-lr-fuse() {
  pacmanRemove rgs-lr-fuse
}

function configure_rgs-lr-fuse() {
  mkRomDir "zxspectrum"

  ensureSystemretroconfig "zxspectrum"

  #Default to 128k spectrum
  setRetroArchCoreOption "fuse_machine" "Spectrum 128K"

  addEmulator 1 "$md_id" "zxspectrum" "$md_inst/fuse_libretro.so"
  addSystem "zxspectrum"
}


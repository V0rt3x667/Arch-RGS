#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-beetle-wswan"
archrgs_module_desc="Bandai WonderSwan & WonderSwan Color Libretro Core"
archrgs_module_help="ROM Extensions: .ws .wsc .zip\n\nCopy Your Wonderswan ROMs to $romdir/wonderswan\n\nCopy Your Wonderswan Color ROMs to $romdir/wonderswancolor"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-wswan-libretro/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-beetle-wswan() {
  pacmanPkg rgs-lr-beetle-wswan
}

function remove_rgs-lr-beetle-wswan() {
  pacmanRemove rgs-lr-beetle-wswan
}

function configure_rgs-lr-beetle-wswan() {
  mkRomDir "wonderswan"
  mkRomDir "wonderswancolor"

  ensureSystemretroconfig "wonderswan"
  ensureSystemretroconfig "wonderswancolor"

  addEmulator 1 "$md_id" "wonderswan" "$md_inst/mednafen_wswan_libretro.so"
  addEmulator 1 "$md_id" "wonderswancolor" "$md_inst/mednafen_wswan_libretro.so"

  addSystem "wonderswan"
  addSystem "wonderswancolor"
}


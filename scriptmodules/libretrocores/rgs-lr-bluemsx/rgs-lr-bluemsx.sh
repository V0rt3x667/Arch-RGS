#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-bluemsx"
archrgs_module_desc="Microsoft MSX, MSX2, Coleco ColecoVision & Sega SG-1000 Libretro Core"
archrgs_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx\nCopy your Colecovision games to $romdir/coleco\n\nrgs-lr-bluemsx requires the BIOS files from the full standalone package of BlueMSX to be copied to '$biosdir/Machines' folder.\nColecovision BIOS needs to be copied to '$biosdir/Machines/COL - ColecoVision\coleco.rom'"
archrgs_module_licence="BSD GPL2 https://raw.githubusercontent.com/libretro/blueMSX-libretro/master/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-bluemsx() {
  pacmanPkg rgs-lr-bluemsx
}

function remove_rgs-lr-bluemsx() {
  pacmanRemove rgs-lr-bluemsx
}

function configure_rgs-lr-bluemsx() {
  mkRomDir "msx"
  mkRomDir "coleco"

  ensureSystemretroconfig "msx"
  ensureSystemretroconfig "coleco"

  addEmulator 1 "$md_id" "msx" "$md_inst/bluemsx_libretro.so"
  addEmulator 1 "$md_id" "coleco" "$md_inst/bluemsx_libretro.so"

  addSystem "msx"
  addSystem "coleco"

  [[ "$md_mode" == "remove" ]] && return

  ##CONFIGURE COLECOVISION SYSTEM
  local core_config="$md_conf_root/coleco/retroarch-core-options.cfg"
  iniConfig " = " '"' "$md_conf_root/coleco/retroarch.cfg"
  iniSet "core_options_path" "$core_config"
  iniSet "bluemsx_msxtype" "ColecoVision" "$core_config"
  chown "$user:$user" "$core_config"
  cp -rv "$md_inst/"{Databases,Machines} "$biosdir/"
  chown -R "$user:$user" "$biosdir/"{Databases,Machines}
}


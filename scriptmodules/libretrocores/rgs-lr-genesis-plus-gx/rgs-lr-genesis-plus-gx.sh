#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-genesis-plus-gx"
archrgs_module_desc="Sega Master System, Game Gear, Mega Drive (Genesis), Sega CD & SG-1000 Libretro Core"
archrgs_module_help="ROM Extensions: .bin .cue .gen .gg .iso .md .sg .smd .sms .zip\nCopy Your Game Gear ROMs to $romdir/gamegear\nMasterSystem ROMs to $romdir/mastersystem\nMegadrive / Genesis ROMs to $romdir/megadrive\nSG-1000 ROMs to $romdir/sg-1000\nSegaCD ROMs to $romdir/segacd\nThe Sega CD requires the BIOS files bios_CD_U.bin and bios_CD_E.bin and bios_CD_J.bin copied to $biosdir"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Genesis-Plus-GX/master/LICENSE.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-genesis-plus-gx() {
  pacmanPkg rgs-lr-genesis-plus-gx
}

function remove_rgs-lr-genesis-plus-gx() {
  pacmanRemove rgs-lr-genesis-plus-gx
}

function configure_rgs-lr-genesis-plus-gx() {
  local system
  local def

  for system in gamegear mastersystem megadrive sg-1000 segacd; do
      def=0
      [[ "$system" == "gamegear" || "$system" == "sg-1000" ]] && def=1
      mkRomDir "$system"
      ensureSystemretroconfig "$system"
      addEmulator "$def" "$md_id" "$system" "$md_inst/genesis_plus_gx_libretro.so"
      addSystem "$system"
  done
}


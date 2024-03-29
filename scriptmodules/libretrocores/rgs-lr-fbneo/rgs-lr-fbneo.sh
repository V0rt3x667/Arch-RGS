#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-fbneo"
archrgs_module_desc="FinalBurn Neo Libretro Core"
archrgs_module_help="ROM Extension: .zip\n\nCopy Your FBA ROMs to\n$romdir/fba or\n$romdir/neogeo or\n$romdir/arcade\n\nFor NeoGeo Games the neogeo.zip BIOS is required and must be placed in the same directory as your FBA ROMs."
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/libretro/FBNeo/master/src/license.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-fbneo() {
  pacmanPkg rgs-lr-fbneo
}

function remove_rgs-lr-fbneo() {
  pacmanRemove rgs-lr-fbneo
}

function configure_rgs-lr-fbneo() {
  addEmulator 0 "$md_id" "arcade" "$md_inst/fbneo_libretro.so"
  addEmulator 0 "$md_id-neocd" "arcade" "$md_inst/fbneo_libretro.so --subsystem neocd"
  addEmulator 1 "$md_id" "neogeo" "$md_inst/fbneo_libretro.so"
  addEmulator 0 "$md_id-neocd" "neogeo" "$md_inst/fbneo_libretro.so --subsystem neocd"
  addEmulator 1 "$md_id" "fba" "$md_inst/fbneo_libretro.so"
  addEmulator 0 "$md_id-neocd" "fba" "$md_inst/fbneo_libretro.so --subsystem neocd"

  addEmulator 0 "$md_id-pce" "pcengine" "$md_inst/fbneo_libretro.so --subsystem pce"
  addEmulator 0 "$md_id-sgx" "pcengine" "$md_inst/fbneo_libretro.so --subsystem sgx"
  addEmulator 0 "$md_id-tg" "pcengine" "$md_inst/fbneo_libretro.so --subsystem tg"
  addEmulator 0 "$md_id-gg" "gamegear" "$md_inst/fbneo_libretro.so --subsystem gg"
  addEmulator 0 "$md_id-sms" "mastersystem" "$md_inst/fbneo_libretro.so --subsystem sms"
  addEmulator 0 "$md_id-md" "megadrive" "$md_inst/fbneo_libretro.so --subsystem md"
  addEmulator 0 "$md_id-sg1k" "sg-1000" "$md_inst/fbneo_libretro.so --subsystem sg1k"
  addEmulator 0 "$md_id-cv" "coleco" "$md_inst/fbneo_libretro.so --subsystem cv"
  addEmulator 0 "$md_id-msx" "msx" "$md_inst/fbneo_libretro.so --subsystem msx"
  addEmulator 0 "$md_id-spec" "zxspectrum" "$md_inst/fbneo_libretro.so --subsystem spec"
  addEmulator 0 "$md_id-fds" "fds" "$md_inst/fbneo_libretro.so --subsystem fds"
  addEmulator 0 "$md_id-nes" "nes" "$md_inst/fbneo_libretro.so --subsystem nes"
  addEmulator 0 "$md_id-ngp" "ngp" "$md_inst/fbneo_libretro.so --subsystem ngp"
  addEmulator 0 "$md_id-ngpc" "ngpc" "$md_inst/fbneo_libretro.so --subsystem ngp"
  addEmulator 0 "$md_id-chf" "channelf" "$md_inst/fbneo_libretro.so --subsystem chf"

  addSystem "arcade"
  addSystem "neogeo"
  addSystem "fba"

  addSystem "pcengine"
  addSystem "gamegear"
  addSystem "mastersystem"
  addSystem "megadrive"
  addSystem "sg-1000"
  addSystem "coleco"
  addSystem "msx"
  addSystem "zxspectrum"
  addSystem "fds"
  addSystem "nes"
  addSystem "ngp"
  addSystem "ngpc"
  addSystem "channelf"

  [[ "$md_mode" == "remove" ]] && return

  local dir
  for dir in arcade fba neogeo; do
    mkRomDir "$dir"
    ensureSystemretroconfig "$dir"
  done

  ##Create Directories For All Support Files
  mkUserDir "$biosdir/fbneo"
  mkUserDir "$biosdir/fbneo/blend"
  mkUserDir "$biosdir/fbneo/cheats"
  mkUserDir "$biosdir/fbneo/patched"
  mkUserDir "$biosdir/fbneo/samples"

  ##Copy hiscore.dat
  cp "$md_inst/data/hiscore.dat" "$biosdir/fbneo/"
  chown "$user:$user" "$biosdir/fbneo/hiscore.dat"

  ##Set Core Options
  setRetroArchCoreOption "fbneo-diagnostic-input" "Hold Start"
}


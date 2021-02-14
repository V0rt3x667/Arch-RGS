#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-openjazz"
archrgs_module_desc="OpenJazz - Open-Source Version of the Classic Jazz Jackrabbit Games"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
archrgs_module_help="For registered version, replace the shareware files by adding your full version game files to $romdir/ports/jazz/."
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-openjazz() {
  pacmanPkg rgs-pt-openjazz
}

function remove_rgs-pt-openjazz() {
  pacmanRemove rgs-pt-openjazz
}

function game_data_rgs-pt-openjazz() {
  if [[ ! -f "$romdir/ports/jazz/JAZZ.EXE" ]]; then
    downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "$romdir/ports/jazz"
    chown -R "$user:$user" "$romdir/ports/jazz"
  fi
}

function configure_rgs-pt-openjazz() {
  addPort "$md_id" "openjazz" "Jazz Jackrabbit" "$md_inst/bin/OpenJazz -f HOMEDIR $romdir/ports/jazz"

  mkRomDir "ports/jazz"

  moveConfigDir "$home/.openjazz" "$md_conf_root/openjazz"

  moveConfigFile "$home/openjazz.cfg" "$md_conf_root/openjazz/openjazz.cfg"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-openjazz
}

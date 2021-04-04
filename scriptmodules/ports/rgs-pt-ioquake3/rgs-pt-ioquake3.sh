#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-ioquake3"
archrgs_module_desc="Quake 3 Arena Port"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/ioquake/ioq3/master/COPYING.txt"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-ioquake3() {
  pacmanPkg rgs-pt-ioquake3
}

function remove_rgs-pt-ioquake3() {
  pacmanRemove rgs-pt-ioquake3
}

function game_data_quake3() {
  if [[ ! -f "$romdir/ports/quake3/pak0.pk3" ]]; then
    downloadAndExtract "$__archive_url/Q3DemoPaks.zip" "$romdir/ports/quake3" -j
  fi
  chown -R "$user:$user" "$romdir/ports/quake3"
}

function configure_rgs-pt-ioquake3() {
  mkRomDir "ports/quake3"

  addPort "$md_id" "quake3" "Quake III Arena" "$md_inst/ioquake3.x86_64"
  addPort "$md_id" "quake3" "Quake III Team Arena" "$md_inst/ioq3ded.x86_64"

  [[ "$md_mode" == "remove" ]] && return

  game_data_quake3

  moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3"
  moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"
}


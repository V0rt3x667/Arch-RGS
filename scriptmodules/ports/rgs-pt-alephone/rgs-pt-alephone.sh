#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-alephone"
archrgs_module_desc="AlephOne - Marathon 2 Game Engine"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/Aleph-One-Marathon/alephone/master/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-alephone() {
  pacmanPkg rgs-pt-alephone
}

function remove_rgs-pt-alephone() {
  pacmanRemove rgs-pt-alephone
}

function _game_data_rgs-pt-alephone() {
  local release_url
  release_url="https://github.com/Aleph-One-Marathon"

  if [[ ! -f "$romdir/ports/alephone/Marathon/Shapes.shps" ]]; then
    downloadAndExtract "$release_url/data-marathon/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-master" "$romdir/ports/alephone/Marathon"
  fi

  if [[ ! -f "$romdir/ports/alephone/Marathon 2/Shapes.shpA" ]]; then
    downloadAndExtract "$release_url/data-marathon-2/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-2-master" "$romdir/ports/alephone/Marathon 2"
  fi

  if [[ ! -f "$romdir/ports/alephone/Marathon Infinity/Shapes.shpA" ]]; then
    downloadAndExtract "$release_url/data-marathon-infinity/archive/master.zip" "$romdir/ports/alephone"
    mv "$romdir/ports/alephone/data-marathon-infinity-master" "$romdir/ports/alephone/Marathon Infinity"
  fi

  chown -R "$user:$user" "$romdir/ports/alephone"
}

function configure_rgs-pt-alephone() {
  addPort "$md_id" "marathon" "Aleph One Engine - Marathon" "'$md_inst/alephone' '$romdir/ports/alephone/Marathon/'"
  addPort "$md_id" "marathon2" "Aleph One Engine - Marathon 2" "'$md_inst/alephone' '$romdir/ports/alephone/Marathon 2/'"
  addPort "$md_id" "marathoninfinity" "Aleph One Engine - Marathon Infinity" "'$md_inst/alephone' '$romdir/ports/alephone/Marathon Infinity/'"

  mkRomDir "ports/alephone"

  moveConfigDir "$home/.alephone" "$md_conf_root/alephone"

  [[ "$md_mode" == "install" ]] && _game_data_rgs-pt-alephone
}


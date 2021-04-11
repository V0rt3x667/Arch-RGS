#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-dhewm3"
archrgs_module_desc="dhewm3 - DOOM 3 Port"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/dhewm/dhewm3/master/COPYING.txt"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-dhewm3() {
  pacmanPkg rgs-pt-dhewm3
}

function remove_rgs-pt-dhewm3() {
  pacmanRemove rgs-pt-dhewm3
}

function game_data_rgs-pt-dhewm3() {
  local url
  url="https://files.holarse-linuxgaming.de/native/Spiele/Doom%203/Demo/doom3-linux-1.1.1286-demo.x86.run"

  if [[ -f "$romdir/ports/doom3/base/pak000.pk4" ]] || [[ -f "$romdir/ports/doom3/demo/demo00.pk4" ]]; then
    return
  else
    download "$url" "$romdir/ports/doom3"
    chmod +x "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
    cd "$romdir/ports/doom3"
    ./doom3-linux-1.1.1286-demo.x86.run --tar xf demo/ && rm "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
    chown -R "$user:$user" "$romdir/ports/doom3/demo"
  fi
}

function add_games_rgs-pt-dhewm3() {
  local cmd="$1"
  local dir
  local pak
  declare -A games=(
    ['base/pak000']="Doom III"
    ['demo/demo00']="Doom III (Demo)"
    ['d3xp/pak000']="Doom III - Resurrection of Evil"
)

  for game in "${!games[@]}"; do
    pak="$romdir/ports/doom3/$game.pk4"
    if [[ -f "$pak" ]]; then
      addPort "$md_id" "doom3" "${games[$game]}" "$cmd" "${game%%/*}"
    fi
  done
}

function configure_rgs-pt-dhewm3() {
  mkRomDir "ports/doom3"

  moveConfigDir "$home/.config/dhewm3" "$md_conf_root/doom3"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-dhewm3

  local basedir

  basedir="$romdir/ports/doom3"

  add_games_rgs-pt-dhewm3 "$md_inst/dhewm3 +set fs_basepath $basedir +set r_fullscreen 1 +set fs_game %ROM%"
}


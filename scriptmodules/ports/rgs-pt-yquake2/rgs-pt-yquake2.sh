#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-yquake2"
archrgs_module_desc="YQuake2 - The Yamagi Quake II Client"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/yquake2/yquake2/master/LICENSE"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-yquake2() {
  pacmanPkg rgs-pt-yquake2
}

function remove_rgs-pt-yquake2() {
  pacmanRemove rgs-pt-yquake2
}

function add_games_rgs-pt-yquake2() {
  local cmd="$1"
  local game
  local pak
  declare -A games=(
    ['baseq2/pak0']="Quake II"
    ['rogue/pak0']="Quake II - Ground Zero"
    ['xatrix/pak0']="Quake II - The Reckoning"
    ['ctf/pak0']="Quake II - Third Wave Capture The Flag"
)

  for game in "${!games[@]}"; do
    pak="$romdir/ports/quake2/$game.pak"
    if [[ -f "$pak" ]]; then
      addPort "$md_id" "quake2" "${games[$game]}" "$cmd" "${game%%/*}"
    fi
  done
}

function game_data_rgs-pt-yquake2() {
  local unwanted

  if [[ ! -f "$romdir/ports/quake2/baseq2/pak1.pak" && ! -f "$romdir/ports/quake2/baseq2/pak0.pak" ]]; then
    ##Get Shareware Game Data
    downloadAndExtract "https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe" "$romdir/ports/quake2/baseq2" -j -LL
  fi

  ##Remove Files That Cause Conflicts
  for unwanted in $(find "$romdir/ports/quake2" -maxdepth 2 -name "*.so" -o -name "*.cfg" -o -name "*.dll" -o -name "*.exe"); do
    rm -f "$unwanted"
  done

  chown -R "$user:$user" "$romdir/ports/quake2"
}

function configure_rgs-pt-yquake2() {
  mkRomDir "ports/quake2"

  moveConfigDir "$home/.yq2" "$md_conf_root/quake2/yquake2"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-yquake2
  add_games_rgs-pt-yquake2 "$md_inst/bin/quake2 -datadir $romdir/ports/quake2 +set r_mode -1 +set vid_fullscreen 1 +set vid_renderer gl3 +set r_vsync 1 +set game %ROM%"
}

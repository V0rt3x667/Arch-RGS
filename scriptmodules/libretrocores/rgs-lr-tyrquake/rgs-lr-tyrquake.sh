#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-tyrquake"
archrgs_module_desc="Quake 1 Libretro Core"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tyrquake/master/gnu.txt"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-tyrquake() {
  pacmanPkg rgs-lr-tyrquake
}

function remove_rgs-lr-tyrquake() {
  pacmanRemove rgs-lr-tyrquake
}

function game_data_rgs-lr-tyrquake() {
  getDepends lhasa

  if [[ ! -f "$romdir/ports/quake/id1/pak0.pak" ]]; then
    cd "$__tmpdir"
    ##Download, Unpack & Install Quake Shareware Files
    downloadAndExtract "http://files.retropie.org.uk/archives/quake106.zip" quake106
    pushd quake106
    lha ef resource.1
    cp -rf id1 "$romdir/ports/quake/"
    popd
    rm -rf quake106
    chown -R $user:$user "$romdir/ports/quake"
    chmod 644 "$romdir/ports/quake/id1/"*
  fi
}

function _add_games_rgs-lr-tyrquake() {
  local cmd="$1"
  local dir
  local pak

  declare -A games=(
    ['id1']="Quake"
    ['hipnotic']="Quake Mission Pack 1 (hipnotic)"
    ['rogue']="Quake Mission Pack 2 (rogue)"
    ['dopa']="Quake Episode 5 (dopa)"
)

  for dir in "${!games[@]}"; do
    pak="$romdir/ports/quake/$dir/pak0.pak"
    if [[ -f "$pak" ]]; then
      addPort "$md_id" "quake" "${games[$dir]}" "$cmd" "$pak"
    fi
  done
}

function add_games_rgs-lr-tyrquake() {
  _add_games_rgs-lr-tyrquake "$md_inst/tyrquake_libretro.so"
}

function configure_rgs-lr-tyrquake() {
  setConfigRoot "ports"

  mkRomDir "ports/quake"

  [[ "$md_mode" == "install" ]] && game_data_rgs-lr-tyrquake

  add_games_rgs-lr-tyrquake

  ensureSystemretroconfig "ports/quake"
}


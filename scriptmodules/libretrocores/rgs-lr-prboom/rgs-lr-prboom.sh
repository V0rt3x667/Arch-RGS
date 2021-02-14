#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-prboom"
archrgs_module_desc="PrBoom (Doom, Doom II, Final Doom & Doom IWAD Mods) Libretro Core"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-prboom/master/COPYING"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-prboom() {
  pacmanPkg rgs-lr-prboom
}

function remove_rgs-lr-prboom() {
  pacmanRemove rgs-lr-prboom
}

function game_data_rgs-lr-prboom() {
  if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
    ##Download Doom 1 Shareware
    wget -nv -O "$romdir/ports/doom/doom1.wad" "$__archive_url/doom1.wad"
  fi

  if [[ ! -f "$romdir/ports/doom/freedoom1.wad" ]]; then
    ##Download Freedoom
    downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" "$romdir/ports/doom/" -j -LL
  fi

  mkUserDir "$romdir/ports/doom/addon"
}

function _add_games_rgs-lr-prboom() {
  local cmd="${@}"
  local addon="$romdir/ports/doom/addon"

  declare -A games=(
    ['doom1.wad']="Doom"
    ['doom2.wad']="Doom II"
    ['doomu.wad']="The Ultimate Doom"
    ['freedoom1.wad']="Freedoom - Phase I"
    ['freedoom2.wad']="Freedoom - Phase II"
    ['tnt.wad']="TNT - Evilution"
    ['plutonia.wad']="The Plutonia Experiment"
)

  if [[ "$md_id" =~ "rgs-pt-gzdoom" ]]; then
    games+=(
    ['heretic.wad']="Heretic - Shadow of the Serpent Riders"
    ['hexen.wad']="Hexen - Beyond Heretic"
    ['hexdd.wad']="Hexen - Deathkings of the Dark Citadel"
    ['chex3.wad']="Chex Quest 3"
    ['strife1.wad']="Strife"
)
  fi

  local game
  local doswad
  local wad

  for game in "${!games[@]}"; do
    doswad="$romdir/ports/doom/${game^^}"
    wad="$romdir/ports/doom/$game"
  if [[ -f "$doswad" ]]; then
    mv "$doswad" "$wad"
  fi
  if [[ -f "$wad" ]]; then
    addPort "$md_id" "doom" "${games[$game]}" "$cmd" "$wad"
    if [[ "$md_id" =~ "rgs-pt-gzdoom" ]]; then
      addPort "$md_id-addon" "doom" "${games[$game]}" "$cmd -file ${addon}/*" "$wad"
    fi
  fi
  done
}

function add_games_rgs-lr-prboom() {
  _add_games_rgs-lr-prboom "$md_inst/prboom_libretro.so"
}

function configure_rgs-lr-prboom() {
  setConfigRoot "ports"

  mkRomDir "ports/doom"

  [[ "$md_mode" == "remove" ]] && return

  ensureSystemretroconfig "ports/doom"

  game_data_rgs-lr-prboom
  add_games_rgs-lr-prboom

  cp $md_inst/prboom.wad "$romdir/ports/doom"
  chown "$user:$user" "$romdir/ports/doom/prboom.wad"
}

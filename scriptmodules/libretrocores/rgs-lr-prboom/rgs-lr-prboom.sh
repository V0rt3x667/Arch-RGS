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
  local dest="$romdir/ports/doom"
  mkUserDir "$dest"
  if [[ ! -f "$dest/doom1.wad" ]]; then
    ##Download Doom 1 Shareware
    download "$__archive_url/doom1.wad" "$dest/doom1.wad"
  fi

  if ! echo "e9bf428b73a04423ea7a0e9f4408f71df85ab175 $romdir/ports/doom/freedoom1.wad" | sha1sum -c &>/dev/null; then
    ##Download or Update Freedoom
    downloadAndExtract "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" "$dest" -j -LL
  fi

  mkUserDir "$dest/addon"
  chown -R "$user:$user" "$dest"
}

function _add_games_rgs-lr-prboom() {
  local cmd="$1"
  local addon="$romdir/ports/doom/addon"

  declare -A games=(
    ['doom.wad']="Doom"
    ['doom1.wad']="Doom (Shareware)"
    ['doomu.wad']="Doom - The Ultimate Doom"
    ['tnt.wad']="Final Doom - TNT:Evilution"
    ['plutonia.wad']="Final Doom - The Plutonia Experiment"
    ['doom2.wad']="Doom II - Hell on Earth"
    ['masterlevels.wad']="Doom II - Master Levels"
    ['freedoom1.wad']="Freedoom - Phase I"
    ['freedoom2.wad']="Freedoom - Phase II"
)

  if [[ "$md_id" =~ "rgs-pt-gzdoom" ]]; then
    games+=(
    ['heretic.wad']="Heretic - Shadow of the Serpent Riders"
    ['hexen.wad']="Hexen - Beyond Heretic"
    ['hexdd.wad']="Hexen - Deathkings of the Dark Citadel"
    ['chex.wad']="Chex Quest"
    ['chex2.wad']="Chex Quest 2"
    ['chex3.wad']="Chex Quest 3"
    ['strife1.wad']="Strife"
    ['hacx.wad']="HacX"
)
  fi

  local game
  local doswad
  local wad

  for game in "${!games[@]}"; do
    doswad="$romdir/ports/doom/${game^^}"
    wad="$romdir/ports/doom/$game"
  ##Change IWADs From Uppercase DOS Names To Lowercase Names
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

  [[ "$md_mode" == "install" ]] && game_data_lr-prboom

  add_games_rgs-lr-prboom

  cp $md_inst/prboom.wad "$romdir/ports/doom"
  chown "$user:$user" "$romdir/ports/doom/prboom.wad"
}


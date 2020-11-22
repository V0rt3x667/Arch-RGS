#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-jumpnbump"
archrgs_module_desc="Jump 'n' Bump Play Cute Bunnies Jumping On Each Other's Heads"
archrgs_module_help="Copy Extra Game Levels (.dat) to $romdir/ports/jumpnbump"
archrgs_module_licence="GPL2 https://gitlab.com/LibreGames/jumpnbump/raw/master/COPYING"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-jumpnbump() {
  pacmanPkg rgs-pt-jumpnbump
}

function remove_rgs-pt-jumpnbump() {
  pacmanRemove rgs-pt-jumpnbump
}

function game_data_rgs-pt-jumpnbump() {
  local tmpdir
  local compressed
  local uncompressed

  tmpdir="$(mktemp -d)"

  ##Install Default Levels
  cp "$md_inst/share/jumpnbump/jumpnbump.dat" "$romdir/ports/jumpnbump"

  ##Install Extra Levels
  downloadAndExtract "https://salsa.debian.org/games-team/jumpnbump-levels/-/archive/master/jumpnbump-levels-master.tar.bz2" \
  "$tmpdir" --strip-components 1 --wildcards "*.bz2"

  for compressed in "$tmpdir"/*.bz2; do
    uncompressed="${compressed##*/}"
    uncompressed="${uncompressed%.bz2}"
      if [[ ! -f "$romdir/ports/jumpnbump/$uncompressed" ]]; then
        bzcat "$compressed" > "$romdir/ports/jumpnbump/$uncompressed"
        chown -R $user:$user "$romdir/ports/jumpnbump/$uncompressed"
      fi
  done
  rm -rf "$tmpdir"
}

function configure_rgs-pt-jumpnbump() {
  addPort "$md_id" "jumpnbump" "Jump 'n Bump" "$md_inst/data/jumpnbump.sh"
  mkRomDir "ports/jumpnbump"

  [[ "$md_mode" == "remove" ]] && return

  ##Install Game Data
  game_data_rgs-pt-jumpnbump

  ##Install Launch Script
  cp "$md_data/jumpnbump.sh" "$md_inst"
  iniConfig "=" '"' "$md_inst/jumpnbump.sh"
  iniSet "ROOTDIR" "$rootdir"
  iniSet "MD_CONF_ROOT" "$md_conf_root"
  iniSet "ROMDIR" "$romdir"
  iniSet "MD_INST" "$md_inst"

  ##Set Default Game Options On First Install
  if [[ ! -f "$md_conf_root/jumpnbump/options.cfg" ]];  then
    iniConfig " = " "" "$md_conf_root/jumpnbump/options.cfg"
    iniSet "nogore" "1"
  fi
}


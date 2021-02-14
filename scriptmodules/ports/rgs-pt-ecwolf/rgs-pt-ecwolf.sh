#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-ecwolf"
archrgs_module_desc="ECWolf - Advanced Source Port for Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark"
archrgs_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/5065aaefe055bff5a8bb8396f7f2ca5f2e2cab27/docs/license-gpl.txt"
archrgs_module_help="Copy Your Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark Game Files to $romdir/ports/wolf3d/"
archrgs_module_section="ports"

function install_bin_rgs-pt-ecwolf() {
  pacmanPkg rgs-pt-ecwolf
}

function remove_rgs-pt-ecwolf() {
  pacmanRemove rgs-pt-ecwolf
}

function game_data_rgs-pt-ecwolf() {
  local dir
  dir="$romdir/ports/wolf3d"

  ##Change Filename Characters to Lowercase
  find $romdir/ports/wolf3d/ -depth -exec perl-rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;

  if [[ ! -f "$dir/vswap.wl6" && ! -f "$dir/vswap.wl1" ]]; then
    cd "$__tmpdir"
    downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d" -j -LL
  fi

  if [[ ! -f "$dir/vswap.sdm" && ! -f "$dir/vswap.sod" && ! -f "$dir/vswap.sd1" ]]; then
    cd "$__tmpdir"
    downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d" -j -LL
  fi

  chown -R "$user:$user" "$romdir/ports/wolf3d"
}

function _add_games_rgs-pt-ecwolf(){
  local cmd="$1"
  local game
  local path="$romdir/ports/wolf3d"

  declare -A games=(
    ['n3d']="Super Noah’s Ark 3D"
    ['sd1']="Wolfenstein 3D - Spear of Destiny"
    ['sd2']="Wolfenstein 3D - Spear of Destiny Mission Pack 2 - Return to Danger"
    ['sd3']="Wolfenstein 3D - Spear of Destiny Mission Pack 3 - Ultimate Challenge"
    ['sdm']="Wolfenstein 3D - Spear of Destiny (Shareware)"
    ['sod']="Wolfenstein 3D - Spear of Destiny"
    ['wl1']="Wolfenstein 3D (Shareware)"
    ['wl6']="Wolfenstein 3D"
)

  for game in "${!games[@]}"; do
    if [[ -f "$path/vswap.$game" ]]; then
      addPort "$md_id" "ecwolf" "${games[$game]}" "$cmd --data $game"
    fi
  done
}

function add_games_rgs-pt-ecwolf() {
  _add_games_rgs-pt-ecwolf "$md_inst/bin/ecwolf"
}

function configure_rgs-pt-ecwolf() {
  mkRomDir "ports/wolf3d"

  moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/ecwolf"
  moveConfigDir "$home/.config/ecwolf" "$md_conf_root/ecwolf"

  [[ "$md_mode" == "install" ]]

  iniConfig " = " '' "$configdir/ports/ecwolf/ecwolf.cfg"

  iniSet "BaseDataPaths" "\"/home/$user/Arch-RGS/roms/ports/wolf3d\";"
  iniSet "Vid_FullScreen" "1;"
  iniSet "Vid_Vsync" "1;"

  game_data_rgs-pt-ecwolf
  add_games_rgs-pt-ecwolf

  chown -R "$user:$user" "$romdir/ports/wolf3d"
}


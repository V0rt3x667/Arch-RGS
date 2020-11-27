#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-wolf4sdl"
archrgs_module_desc="Wolf4SDL - Port of Wolfenstein 3D & Spear of Destiny"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/AlumiuN/Wolf4SDL/master/license-gpl.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-wolf4sdl() {
  pacmanPkg rgs-pt-wolf4sdl
}

function remove_rgs-pt-wolf4sdl() {
  pacmanRemove rgs-pt-wolf4sdl
}

function _get_opts_rgs-pt-wolf4sdl() {
  echo 'wolf4sdl-sw-v14 -DCARMACIZED -DUPLOAD' ##Shareware v1.4
  echo 'wolf4sdl-3dr-v14 -DCARMACIZED' ##3D Realms & Apogee v1.4 Full
  echo 'wolf4sdl-gt-v14 -DCARMACIZED -DGOODTIMES' ##GT, id & Activision v1.4 Full
  echo 'wolf4sdl-spear -DCARMACIZED -DGOODTIMES -DSPEAR' ##Spear of Destiny
  echo 'wolf4sdl-spear-sw -DCARMACIZED -DSPEARDEMO -DSPEAR' ##Spear of Destiny Demo
}

function add_games_rgs-pt-wolf4sdl() {
  declare -A -g games_wolf4sdl=(
    ['vswap.wl1']="Wolfenstein 3D Demo"
    ['vswap.wl6']="Wolfenstein 3D"
    ['vswap.sd1']="Wolfenstein 3D - Spear of Destiny Ep 1"
    ['vswap.sd2']="Wolfenstein 3D - Spear of Destiny Ep 2"
    ['vswap.sd3']="Wolfenstein 3D - Spear of Destiny Ep 3"
    ['vswap.sdm']="Wolfenstein 3D - Spear of Destiny Demo"
)

  add_ports_rgs-pt-wolf4sdl "$md_inst/bin/wolf4sdl.sh %ROM%" "wolf3d"
}

function add_ports_rgs-pt-wolf4sdl() {
  local port="$2"
  local cmd="$1"
  local game
  local wad

  for game in "${!games_wolf4sdl[@]}"; do
    wad="$romdir/ports/wolf3d/$game"
    if [[ -f "$wad" ]]; then
      addPort "$md_id" "$port" "${games_wolf4sdl[$game]}" "$cmd" "$wad"
    fi
  done
}

function game_data_rgs-pt-wolf4sdl() {
  if [[ ! -f "$romdir/ports/wolf3d/vswap.wl6" && ! -f "$romdir/ports/wolf3d/vswap.wl1" ]]; then
    cd "$__tmpdir"
    ##Get Shareware game Data
    downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d" -j -LL
  fi
  if [[ ! -f "$romdir/ports/wolf3d/vswap.sdm" && ! -f "$romdir/ports/wolf3d/vswap.sod" ]]; then
    cd "$__tmpdir"
    ##Get Shareware Game Data
    downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d" -j -LL
  fi

  chown -R "$user:$user" "$romdir/ports/wolf3d"
}

function configure_rgs-pt-wolf4sdl() {
  local game

  mkRomDir "ports/wolf3d"

  ##Remove Obsolete Emulator Entries
  while read game; do
    delEmulator "${game%% *}" "wolf3d"
  done < <(_get_opts_rgs-pt-wolf4sdl; echo -e "wolf4sdl-spear2\nwolf4sdl-spear3")

  if [[ "$md_mode" == "install" ]]; then
    game_data_rgs-pt-wolf4sdl
    cat > "$md_inst/bin/wolf4sdl.sh" << _EOF_
#!/bin/bash

function get_md5sum() {
  local file="\$1"

  [[ -n "\$file" ]] && md5sum "\$file" 2>/dev/null | cut -d" " -f1
}

function launch_rgs-pt-wolf4sdl() {
  local wad_file="\$1"
  declare -A game_checksums=(
    ['6efa079414b817c97db779cecfb081c9']="wolf4sdl-sw-v14"
    ['a6d901dfb455dfac96db5e4705837cdb']="wolf4sdl-3dr-v14"
    ['b8ff4997461bafa5ef2a94c11f9de001']="wolf4sdl-gt-v14"
    ['b1dac0a8786c7cdbb09331a4eba00652']="wolf4sdl-spear --mission 1"
    ['25d92ac0ba012a1e9335c747eb4ab177']="wolf4sdl-spear --mission 2"
    ['94aeef7980ef640c448087f92be16d83']="wolf4sdl-spear --mission 3"
    ['35afda760bea840b547d686a930322dc']="wolf4sdl-spear-sw"
)
  if [[ "\${game_checksums[\$(get_md5sum \$wad_file)]}" ]] 2>/dev/null; then
    $md_inst/bin/\${game_checksums[\$(get_md5sum \$wad_file)]}
  else
    echo "Error: \$wad_file (md5: \$(get_md5sum \$wad_file)) is not a supported version"
  fi
}

launch_rgs-pt-wolf4sdl "\$1"
_EOF_
  chmod +x "$md_inst/bin/wolf4sdl.sh"
  fi

  add_games_rgs-pt-wolf4sdl

  moveConfigDir "$home/.wolf4sdl" "$md_conf_root/wolf3d"
}

#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-splitwolf"
archrgs_module_desc="SplitWolf - 2-4 Player Split-Screen Wolfenstein 3D & Spear of Destiny Port"
archrgs_module_help="Game File Extension: .wl6, .sod, .sd2, .sd3\n\nCopy your game files to $romdir/ports/wolf3d/\n\nIf you add new game files, run: sudo ~/archrgs_setup/archrgs_packages.sh rgs-pt-splitwolf configure"
archrgs_module_licence="NONCOM https://bitbucket.org/linuxwolf6/splitwolf/raw/scrubbed/license-mame.txt"
archrgs_module_section="ports"

function _get_opts_rgs-pt-splitwolf() {
  echo 'splitwolf-wolf3d VERSION_WOLF3D_SHAREWARE=y'     ##Shareware v1.4
  echo 'splitwolf-wolf3d_apogee VERSION_WOLF3D_APOGEE=y' ##3D Realms & Apogee v1.4 Full
  echo 'splitwolf-wolf3d_full VERSION_WOLF3D=y'          ##GT, id & Activision v1.4 Full
  echo 'splitwolf-sod VERSION_SPEAR=y'                   ##Spear of Destiny
  echo 'splitwolf-sodmp VERSION_SPEAR_MP=y'              ##Spear of Destiny Mission Packs
  echo 'splitwolf-spear_demo VERSION_SPEAR_DEMO=y'       ##Spear of Destiny
}

function game_data_rgs-pt-splitwolf() {
  if [[ ! -d "$md_inst/bin/lwmp" ]]; then
    ##Get Game Assets
    downloadAndExtract "https://bitbucket.org/linuxwolf6/splitwolf/downloads/lwmp.zip" "$md_inst/bin/"
  fi
}

function add_games_rgs-pt-splitwolf() {
  declare -A games_wolf4sdl=(
    ['vswap.wl1']="Splitwolf - Wolf 3D Demo"
    ['vswap.wl6']="Splitwolf - Wolf 3D"
    ['vswap.sod']="Splitwolf - Spear of Destiny Ep 1"
    ['vswap.sd2']="Splitwolf - Spear of Destiny Ep 2"
    ['vswap.sd3']="Splitwolf - Spear of Destiny Ep 3"
    ['vswap.sdm']="Splitwolf - Spear of Destiny Demo"
  )

  add_ports_rgs-pt-wolf4sdl "$md_inst/bin/splitwolf.sh %ROM%" "splitwolf"
}

function install_bin_rgs-pt-splitwolf() {
  pacmanPkg rgs-pt-splitwolf
}

function remove_rgs-pt-splitwolf() {
  pacmanRemove rgs-pt-splitwolf
}

function configure_rgs-pt-splitwolf() {
  local game

  mkRomDir "ports/wolf3d"

  if [[ "$md_mode" == "install" ]]; then
    game_data_rgs-pt-splitwolf
    game_data_rgs-pt-wolf4sdl

    cat >"$md_inst/bin/splitwolf.sh" <<_EOF_
#!/bin/bash

function get_md5sum() {
  local file="\$1"

  [[ -n "\$file" ]] && md5sum "\$file" 2>/dev/null | cut -d" " -f1
}

function launch_splitwolf() {
  local wad_file="\$1"
  declare -A game_checksums=(
    ['6efa079414b817c97db779cecfb081c9']="splitwolf-wolf3d"
    ['a6d901dfb455dfac96db5e4705837cdb']="splitwolf-wolf3d_apogee"
    ['b8ff4997461bafa5ef2a94c11f9de001']="splitwolf-wolf3d_full"
    ['b1dac0a8786c7cdbb09331a4eba00652']="splitwolf-sod"
    ['25d92ac0ba012a1e9335c747eb4ab177']="splitwolf-sodmp --mission 2"
    ['94aeef7980ef640c448087f92be16d83']="splitwolf-sodmp --mission 3"
    ['35afda760bea840b547d686a930322dc']="splitwolf-spear_demo"
)

  if [[ "\${game_checksums[\$(get_md5sum \$wad_file)]}" ]] 2>/dev/null; then
    $md_inst/bin/\${game_checksums[\$(get_md5sum \$wad_file)]} --splitdatadir $md_inst/bin/lwmp/ --split 2 --splitlayout 2x1
    else
    echo "Error: \$wad_file (md5: \$(get_md5sum \$wad_file)) is not a supported version"
  fi
}

launch_splitwolf "\$1"
_EOF_
    chmod +x "$md_inst/bin/splitwolf.sh"
  fi

  add_games_rgs-pt-splitwolf

  moveConfigDir "$home/.splitwolf" "$md_conf_root/splitwolf"
}

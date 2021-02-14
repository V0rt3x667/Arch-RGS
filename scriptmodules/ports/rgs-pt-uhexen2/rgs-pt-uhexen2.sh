#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-uhexen2"
archrgs_module_desc="Hexen II Source Port"
archrgs_module_licence="GPL2 https://sourceforge.net/projects/uhexen2/"
archrgs_module_help="Add your full version PAK files to $romdir/ports/hexen2/data1/ and $romdir/ports/hexen2/portals/ to play. The files for Hexen II are: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-uhexen2() {
  pacmanPkg rgs-pt-uhexen2
}

function remove_rgs-pt-uhexen2() {
  pacmanRemove rgs-pt-uhexen2
}

function add_games_rgs-pt-uhexen2() {
  local game
  local dir="$romdir/ports/hexen2"
  declare -A games=(
    ['pak0.pak']="Hexen II"
    ['pak3.pak']="Hexen II - Portal of Praevus"
)

  for game in "${!games[@]}"; do
    if [[ -f $dir/portals/pak3.pak ]]; then
      addPort "$md_id" "hexen2" "${games[$game]}" "$md_inst/bin/glhexen2 -f -vsync -portals" "${game%%/*}"
    elif [[ -f $dir/data1/pak0.pak ]]; then
      addPort "$md_id" "hexen2" "${games[$game]}" "$md_inst/bin/glhexen2 -f -vsync" "${game%%/*}"
    fi
  done
}

function game_data_rgs-pt-uhexen2() {
  if [[ ! -f "$romdir/ports/hexen2/data1/pak0.pak" ]]; then
    downloadAndExtract "https://netix.dl.sourceforge.net/project/uhexen2/Hexen2Demo-Nov.1997/hexen2demo_nov1997-linux-i586.tgz" \
    "$romdir/ports/hexen2" --strip-components 1 "hexen2demo_nov1997/data1"
    chown -R "$user:$user" "$romdir/ports/hexen2/data1"
  fi
}

function configure_rgs-pt-uhexen2() {
  mkRomDir "ports/hexen2"

  moveConfigDir "$home/.hexen2" "$romdir/ports/hexen2"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-uhexen2
  add_games_rgs-pt-uhexen2
}

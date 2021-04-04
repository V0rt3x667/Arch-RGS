#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-raze"
archrgs_module_desc="Raze Build Engine Port"
archrgs_module_help="ROM Extensions: .grp\n\nCopy your .grp files to $romdir/ports/{blood,duke3d,exhumed,redneck,sw,wh}"
archrgs_module_licence="GPL2 & NONCOM: https://raw.githubusercontent.com/coelckers/Raze/master/build-doc/buildlic.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-raze() {
  pacmanPkg rgs-pt-raze
}

function remove_rgs-pt-raze() {
  pacmanRemove rgs-pt-raze
}

function add_games_rgs-pt-raze() {
  local cmd="$1"
  local file

  declare -A games=(
    ['blood/blood.rff']="Blood"
    ['blood/cryptic/cryptic.ini']="Blood - Cryptic Passage"
    ['duke3d/duke3d.grp']="Duke Nukem 3D"
    ['duke3d/dukedc/dukedc.grp']="Duke Nukem 3D - Duke It Out in D.C."
    ['duke3d/vacation/vacation.grp']="Duke Nukem 3D - Duke Caribbean - Life's a Beach"
    ['duke3d/nwinter/nwinter.grp']="Duke Nukem 3D - Nuclear Winter"
    ['exhumed/stuff.dat']="Exhumed - PowerSlave"
    ['nam/nam.grp']="NAM"
    ['redneck/redneck.grp']="Redneck Rampage"
    ['redneck/game66.con']="Redneck Rampage - Suckin' Grits on Route 66"
    ['rrragain/redneck.grp']="Redneck Rampage - Redneck Rampage Rides Again"
    ['sw/sw.grp']="Shadow Warrior"
    ['sw/wt.grp']="Shadow Warrior - Wanton Destruction"
    ['sw/td.grp']="Shadow Warrior - Twin Dragon"
    ['ww2gi/ww2gi.grp']="World War II GI"
    ['ww2gi/platoonl.dat']="World War II GI - Platoon Leader"
)

  for game in "${!games[@]}"; do
    file="$romdir/ports/$game"
    if [[ "${game}" != blood/cryptic/cryptic.ini && "${game}" != redneck/game66.con ]] && [[ -f "$file" ]]; then
      addPort "$md_id" "${game%%/*}" "${games[$game]}" "$cmd -game_dir $romdir/ports/${game%%/*}" "$file"
    elif [[ "${game}" == blood/cryptic/cryptic.ini ]] && [[ -f "$file" ]]; then
      addPort "$md_id" "cryptic" "${games[$game]}" "$cmd -cryptic -game_dir $romdir/ports/blood/cryptic" "$romdir/ports/blood/blood.rff"
    elif [[ "${game}" == redneck/game66.con ]] && [[ -f "$file" ]]; then
      addPort "$md_id" "route66" "${games[$game]}" "$cmd -route66 -game_dir $romdir/ports/redneck" "$romdir/ports/redneck/redneck.grp"
    fi
  done
}

function configure_rgs-pt-raze() {
  local dir
  dir=(
    'blood'
    'duke3d' 
    'exhumed'
    'nam'
    'redneck'
    'rrragain'
    'sw'
    'ww2gi' 
)

  for d in "${dir[@]}"; do
    mkRomDir "ports/${d}"
  done

  moveConfigDir "$home/.config/raze" "$md_conf_root/raze"

  [[ "$md_mode" == "install" ]]

  add_games_rgs-pt-raze "$md_inst/raze -iwad %ROM% +vid_renderer 1 +vid_fullscreen 1"
}


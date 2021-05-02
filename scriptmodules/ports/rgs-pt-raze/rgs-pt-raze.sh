#!/usr/bin/bash -x

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
  local game
  local grp

  declare -A games=(
    ['blood/blood.rff']="Blood"
    ['blood/cryptic.ini']="Blood - Cryptic Passage"
    ['duke3d/duke3d.grp']="Duke Nukem 3D"
    ['duke3d/dukedc.grp']="Duke Nukem 3D - Duke It Out in D.C."
    ['duke3d/vacation.grp']="Duke Nukem 3D - Duke Caribbean - Life's a Beach"
    ['duke3d/nwinter.grp']="Duke Nukem 3D - Duke - Nuclear Winter"
    ['exhumed/stuff.dat']="Exhumed (AKA PowerSlave)"
    ['nam/nam.grp']="NAM (AKA Napalm)"
    ['nam/napalm.grp']="Napalm (AKA NAM)"
    ['redneck/redneck.grp']="Redneck Rampage"
    ['redneck/game66.con']="Redneck Rampage - Suckin' Grits on Route 66"
    ['redneckrides/redneck.grp']="Redneck Rampage - Redneck Rampage Rides Again"
    ['shadow/sw.grp']="Shadow Warrior"
    ['shadow/td.grp']="Shadow Warrior - Twin Dragon"
    ['shadow/wt.grp']="Shadow Warrior - Wanton Destruction"
    ['ww2gi/ww2gi.grp']="World War II GI"
    ['ww2gi/platoonl.dat']="World War II GI - Platoon Leader"
)

  for game in "${!games[@]}"; do
    file="$romdir/ports/raze/${game}"
    grp="${game#*/}"
    ##Add Games Which Do Not Require Additional Parameters
    if [[ "${game}" != blood/cryptic.ini && "${game}" != redneck/game66.con && -f "$file" ]]; then
      addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -iwad $grp"
    ##Add Blood: Cryptic Passage
    elif [[ "${game}" == blood/cryptic.ini && -f "$file" ]]; then
      addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -cryptic"
    ##Add Redneck Rampage: Suckin' Grits on Route 66
    elif [[ "${game}" == redneck/game66.con && -f "$file" ]]; then
      addPort "$md_id" "${game#*/}" "${games[$game]}" "$cmd -route66"
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
    'redneckrides'
    'shadow'
    'ww2gi' 
)

  for d in "${dir[@]}"; do
    mkRomDir "ports/raze/${d}"
  done

  moveConfigDir "$home/.config/raze" "$md_conf_root/raze"

  [[ "$md_mode" == "install" ]]

  add_games_rgs-pt-raze "$md_inst/raze +vid_renderer 1 +vid_fullscreen 1"
}


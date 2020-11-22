#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-frotz"
archrgs_module_desc="Frotz - Interpreter for Infocom & Z-Machine Games"
archrgs_module_help="ROM Extensions: .dat .zip .z1 .z2 .z3 .z4 .z5 .z6 .z7 .z8\n\nCopy your Infocom games to $romdir/zmachine"
archrgs_module_licence="GPL2 https://gitlab.com/DavidGriffith/frotz/raw/master/COPYING"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-frotz() {
  pacmanPkg rgs-em-frotz
}

function remove_rgs-em-frotz() {
  pacmanRemove rgs-em-frotz
}

function game_data_rgs-em-frotz() {
  if [[ ! -f "$romdir/zmachine/zork1.dat" ]]; then
    cd "$__tmpdir"
    local file
    for file in zork1 zork2 zork3; do
      wget -nv -O "$file.zip" "$__archive_url/$file.zip"
      unzip -L -n "$file.zip" "data/$file.dat"
      mv "data/$file.dat" "$romdir/zmachine/"
      chown "$user:$user" "$romdir/zmachine/$file.dat"
      rm "$file.zip"
    done
    rmdir data
  fi
}

function configure_rgs-em-frotz() {
  mkRomDir "zmachine"

  moveConfigDir "$home/.config/frotzrc" "$md_conf_root/zmachine/frotz"

  ##CON: Stop runcommand From Redirecting stdout to Log
  addEmulator 1 "$md_id" "zmachine" "CON:pushd $romdir/zmachine; $md_inst/bin/sfrotz -F %ROM%; popd"
  addSystem "zmachine"

  [[ "$md_mode" == "install" ]] && game_data_rgs-em-frotz
}


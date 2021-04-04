#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-linapple-pie"
archrgs_module_desc="LinApple - Apple 2 & 2e Emulator"
archrgs_module_help="ROM Extensions: .dsk\n\nCopy your Apple 2 games to $romdir/apple2"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/dabonetn/linapple-pie/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-linapple-pie() {
  pacmanPkg rgs-em-linapple-pie
}

function remove_rgs-em-linapple-pie() {
  pacmanRemove rgs-em-linapple-pie
}

function configure_rgs-em-linapple-pie() {
  mkRomDir "apple2"

  addEmulator 1 "$md_id" "apple2" "$md_inst/linapple.sh -1 %ROM%"
  addSystem "apple2"

  [[ "$md_mode" == "remove" ]] && return

  ##Copy Default Config & Disk
  local file
  for file in Master.dsk linapple.conf; do
    copyDefaultConfig "$file" "$md_conf_root/apple2/$file"
  done

  mkUserDir "$md_conf_root/apple2"

  moveConfigDir "$home/.linapple" "$md_conf_root/apple2"

  local file
  file="$md_inst/linapple.sh"
  cat >"$file" << _EOF_
#!/usr/bin/env bash
pushd "$romdir/apple2"
$md_inst/bin/linapple "\$@"
popd
_EOF_
  chmod +x "$file"
}


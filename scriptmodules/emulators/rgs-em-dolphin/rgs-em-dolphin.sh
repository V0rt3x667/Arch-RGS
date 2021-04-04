#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-dolphin"
archrgs_module_desc="Dolphin - Nintendo Gamecube, Wii & Triforce Emulator"
archrgs_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy your gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/license.txt"
archrgs_module_section="emulators"

function install_bin_rgs-em-dolphin() {
  pacmanPkg rgs-em-dolphin
}

function remove_rgs-em-dolphin() {
  pacmanRemove rgs-em-dolphin
}

function configure_rgs-em-dolphin() {
  mkRomDir "gc"
  mkRomDir "wii"

  moveConfigDir "$home/.dolphin-emu" "$md_conf_root/gc"

  if [[ "$md_mode" == "install" ]] && [[ ! -f "$md_conf_root/gc/Config/Dolphin.ini" ]]; then
    mkdir -p "$md_conf_root/gc/Config"
    cat >"$md_conf_root/gc/Config/Dolphin.ini" <<_EOF_
[Display]
FullscreenResolution = Auto
Fullscreen = True
_EOF_
    chown -R "$user:$user" "$md_conf_root/gc/Config"
  fi

  addEmulator 1 "$md_id" "gc" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
  addEmulator 0 "$md_id-gui" "gc" "$md_inst/bin/dolphin-emu -b -e %ROM%"
  addEmulator 1 "$md_id" "wii" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
  addEmulator 0 "$md_id-gui" "wii" "$md_inst/bin/dolphin-emu -b -e %ROM%"
  addSystem "gc"
  addSystem "wii"
}


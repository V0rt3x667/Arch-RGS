#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-zesarux"
archrgs_module_desc="ZEsarUX - Sinclair Zx80, Zx81, Z88, Zx Spectrum 16, 48, 128, +2, +2A & ZX-Uno Emulator"
archrgs_module_help="ROM Extensions: .sna .szx .z80 .tap .tzx .gz .udi .mgt .img .trd .scl .dsk .zip\n\nCopy your ZX Spectrum games to $romdir/zxspectrum"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/chernandezba/zesarux/master/src/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-zesarux() {
  pacmanPkg rgs-em-zesarux
}

function remove_rgs-em-zesarux() {
  pacmanRemove rgs-em-zesarux
}

function configure_rgs-em-zesarux() {
  mkRomDir "zxspectrum"
  mkRomDir "amstradcpc"
  mkRomDir "samcoupe"

  mkUserDir "$md_conf_root/zxspectrum"

  cat > "$romdir/zxspectrum/+Start ZEsarUX.sh" << _EOF_
#!/usr/bin/env bash
"$md_inst/bin/zesarux" "\$@"
_EOF_
  chmod +x "$romdir/zxspectrum/+Start ZEsarUX.sh"
  chown "$user:$user" "$romdir/zxspectrum/+Start ZEsarUX.sh"

  moveConfigFile "$home/.zesaruxrc" "$md_conf_root/zxspectrum/.zesaruxrc"

  local ao
  local config
  ao="pulse"
  config="$(mktemp)"

  cat > "$config" << _EOF_
;ZEsarUX sample configuration file
;
;Lines beginning with ; or # are ignored

;Run zesarux with --help or --experthelp to see all the options
--disableborder
--disablefooter
--vo sdl
--ao $ao
--hidemousepointer
--fullscreen

--smartloadpath $romdir/zxspectrum

--joystickemulated Kempston

;Remap Fire Event. Uncomment and amend if you wish to change the default button 3.
;--joystickevent 3 Fire
;Remap On-screen keyboard. Uncomment and amend if you wish to change the default button 5.
;--joystickevent 5 Osdkeyboard
_EOF_

  copyDefaultConfig "$config" "$md_conf_root/zxspectrum/.zesaruxrc"
  rm "$config"

  addEmulator 1 "$md_id" "zxspectrum" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh %ROM%"
  addEmulator 0 "$md_id" "samcoupe" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine sam %ROM%"
  addEmulator 0 "$md_id" "amstradcpc" "bash $romdir/zxspectrum/+Start\ ZEsarUX.sh --machine CPC464 %ROM%"
  addSystem "zxspectrum"
  addSystem "samcoupe"
  addSystem "amstradcpc"
}


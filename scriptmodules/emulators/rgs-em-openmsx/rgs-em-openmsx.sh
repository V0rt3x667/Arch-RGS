#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-openmsx"
archrgs_module_desc="OpenMSX - Microsoft MSX, MSX2, MSX2+ & TurboR Emulator"
archrgs_module_help="ROM Extensions: .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx\nCopy the BIOS files to $biosdir/openmsx"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/openMSX/openMSX/master/doc/GPL.txt"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-openmsx() {
  pacmanPkg rgs-em-openmsx
}

function remove_rgs-em-openmsx() {
  pacmanRemove rgs-em-openmsx    
}

function configure_rgs-em-openmsx() {
  mkRomDir "msx"
  mkRomDir "msx2"

  addEmulator 1 "$md_id" "msx" "$md_inst/bin/openmsx %ROM%"
  addEmulator 1 "$md_id-msx2" "msx" "$md_inst/bin/openmsx -machine 'Boosted_MSX2_EN' %ROM%"
  addEmulator 0 "$md_id-msx2-plus" "msx" "$md_inst/bin/openmsx -machine 'Boosted_MSX2+_JP' %ROM%"
  addEmulator 0 "$md_id-msx-turbor" "msx" "$md_inst/bin/openmsx -machine 'Panasonic_FS-A1GT' %ROM%"
  addSystem "msx"
  addSystem "msx2"

  [[ $md_mode == "remove" ]] && return

  ##Add a Minimal Configuration
  local config
  config="$(mktemp)"
  echo "$(_default_settings_openmsx)" > "$config"

  mkUserDir "$home/.openMSX/share/scripts"
  mkUserDir "$home/.openMSX/share/systemroms"

  moveConfigDir "$home/.openMSX" "$configdir/msx/openmsx"
  moveConfigDir "$configdir/msx/openmsx/share/systemroms" "$home/ARCH-RGS/BIOS/openmsx"

  ##Add System ROMs
  downloadAndExtract "$__archive_url/openmsxroms.tar.gz" "$home/ARCH-RGS/BIOS/openmsx"

  copyDefaultConfig "$config" "$home/.openMSX/share/settings.xml"
  rm "$config"

  ##Add Autostart Script, for Joypad Configuration
  cp "$md_data/archrgs-init.tcl" "$home/.openMSX/share/scripts"
  chown -R "$user:$user" "$home/.openMSX/share/scripts"
}

function _default_settings_rgs-em-openmsx() {
  local header
  local body
  local conf_reverse

  read -r -d '' header <<_EOF_
<!DOCTYPE settings SYSTEM 'settings.dtd'>
<settings>
  <settings>
    <setting id="default_machine">C-BIOS_MSX</setting>
    <setting id="osd_disk_path">$romdir/msx</setting>
    <setting id="osd_rom_path">$romdir/msx</setting>
    <setting id="osd_tape_path">$romdir/msx</setting>
    <setting id="osd_hdd_path">$romdir/msx</setting>
    <setting id="fullscreen">true</setting>
    <setting id="save_settings_on_exit">false</setting>
_EOF_
}


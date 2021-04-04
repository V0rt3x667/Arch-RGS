#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-reicast"
archrgs_module_desc="Reicast - Sega Dreamcast Emulator"
archrgs_module_help="ROM Extensions: .cdi .chd .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
archrgs_module_licence="BSD & GPL2 https://raw.githubusercontent.com/reicast/reicast-emulator/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-reicast() {
  pacmanPkg rgs-em-reicast
}

function remove_rgs-em-reicast() {
  pacmanRemove rgs-em-reicast
}

function configure_rgs-em-reicast() {
  mkRomDir "dreamcast"

  moveConfigDir "$home/.config/reicast" "$md_conf_root/dreamcast"
  moveConfigDir "$biosdir/dc/" "$md_conf_root/dreamcast/data"

  addEmulator 1 "$md_id" "dreamcast" "$md_inst/bin/reicast.sh ${params[*]}"
  addSystem "dreamcast"
  addAutoConf reicast_input 1

  [[ "$md_mode" == "remove" ]] && rm "$romdir/dreamcast/+Start Reicast.sh" && return

  install -Dm755 "$md_inst"/share/reicast/mappings/*.cfg -t "$md_conf_root/dreamcast/mappings"
  chown -R "$user:$user" "$md_conf_root/dreamcast"

  ##Copy Hotkey Remapping Start Script
  install -Dm755 "$md_data/reicast.sh" -t "$md_inst/bin"

  cat > "$romdir/dreamcast/+Start Reicast.sh" << _EOF_
#!/usr/bin/env bash
  $md_inst/bin/reicast.sh
_EOF_
  chmod a+x "$romdir/dreamcast/+Start Reicast.sh"
  chown "$user:$user" "$romdir/dreamcast/+Start Reicast.sh"
}

function input_rgs-em-reicast() {
  local temp_file
  local mapping_file
  temp_file="$(mktemp)"
  mapping_file="$configdir/dreamcast/mappings/evdev_${ini_value//[:><?\"]/-}.cfg"

  cd "$md_inst/bin"

  ./reicast-joyconfig -f "$temp_file" >/dev/tty
  iniConfig " = " "" "$temp_file"
  iniGet "mapping_name"
  mv "$temp_file" "$mapping_file"
  chown "$user:$user" "$mapping_file"
}

function gui_rgs-em-reicast() {
  local options
  local choice
  local cmd

  while true; do
    options=(
      1 "Configure input devices for Reicast"
    )
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break
    case "$choice" in
      1)
        clear
        input_rgs-em-reicast
      ;;
    esac
  done
}


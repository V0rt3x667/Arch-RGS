#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="archrgs_menu"
archrgs_module_desc="Arch-RGS Configuration Menu for EmulationStation"
archrgs_module_section="core"

function _update_hook_archrgs_menu() {
  ##SHOW AS INSTALLED WHEN UPGRADING
  if ! archrgs_isInstalled "$md_idx" && [[ -f "$home/.emulationstation/gamelists/archrgs/gamelist.xml" ]]; then
    mkdir -p "$md_inst"
    ##STOP OLDER SCRIPTS REMOVING WHEN LAUNCHING FROM THE ARCHRGS MENU IN ES
    ##DUE TO NOT USING EXEC OR EXITING AFTER RUNNING ARCHRGS-SETUP FROM THIS MODULE
    touch "$md_inst/.archrgs"
  fi
}

function depends_archrgs_menu() {
  getDepends mc
}

function install_bin_archrgs_menu() {
  return
}

function configure_archrgs_menu() {
  [[ "$md_mode" == "remove" ]] && return

  local rgsdir="$home/Arch-RGS/archrgs_menu"
  mkdir -p "$rgsdir"
  cp -Rv "$md_data/icons" "$rgsdir"
  chown -R "$user:$user" "$rgsdir"

  ##ADD THE GAMESLIST AND ICONS
  local files=(
    'bluetooth'
    'configedit'
    'esthemes'
    'filemanager'
    'retroarch'
    'retronetplay'
    'rgssetup'
    'runcommand'
    'showip'
    'wifi'
  )

  local names=(
    'Bluetooth'
    'Configuration Editor'
    'ES Themes'
    'File Manager'
    'Retroarch'
    'RetroArch Net Play'
    'Arch-RGS Setup'
    'Run Command Configuration'
    'Show IP'
    'WiFi'
  )

  local descs=(
    'Register and connect to bluetooth devices. Unregister and remove devices, and display registered and connected devices.'
    'Change common RetroArch options, and manually edit RetroArch configs, global configs, and non-RetroArch configs.'
    'Install, uninstall, or update EmulationStation themes. Most themes can be previewed at https://github.com/retropie/ RetroPie-Setup/wiki/themes.'
    'Basic ASCII file manager for linux allowing you to browse, copy, delete, and move files.'
    'Launches the RetroArch GUI so you can change RetroArch options. Note: Changes will not be saved unless you have enabled the "Save Configuration On Exit" option.'
    'Set up RetroArch Netplay options, choose host or client, port, host IP, delay frames, and your nickname.'
    'Install Arch-RGS, install experimental packages, additional drivers, edit samba shares, custom scraper, as well as other Arch-RGS-related configurations.'
    'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art.'
    'Displays your current IP address, as well as other information provided by the command, "ip addr show."'
    'Connect to or disconnect from a wifi network and configure wifi settings.'
  )

  setESSystem "Arch-RGS" "archrgs" "$rgsdir" ".rgs .sh" "sudo $scriptdir/archrgs_packages.sh archrgs_menu launch %ROM% </dev/tty >/dev/tty" "" "archrgs"

  local file
  local name
  local desc
  local image
  local i

  for i in "${!files[@]}"; do
    file="${files[i]}"
    name="${names[i]}"
    desc="${descs[i]}"
    image="$home/Arch-RGS/archrgs_menu/icons/${files[i]}.png"
    touch "$rgsdir/$file.rgs"
    local function
    for function in $(compgen -A function _add_rom_); do
      "$function" "archrgs" "Arch-RGS" "$file.rgs" "$name" "$desc" "$image"
    done
  done
}

function remove_archrgs_menu() {
  rm -rf "$home/Arch-RGS/archrgs_menu"
  rm -rf "$home/.emulationstation/gamelists/archrgs"
  delSystem archrgs
}

function launch_archrgs_menu() {
  clear
  local command="$1"
  local basename="${command##*/}"
  local no_ext="${basename%.rgs}"
  joy2keyStart
  case "$basename" in
  retroarch.rgs)
    joy2keyStop
    cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
    chown "$user:$user" "$configdir/all/retroarch.cfg.bak"
    su "$user" -c "\"$emudir/rgs-em-retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
    iniConfig " = " '"' "$configdir/all/retroarch.cfg"
    iniSet "config_save_on_exit" "false"
    ;;
  rgssetup.rgs)
    archrgs_callModule setup gui
    ;;
  filemanager.rgs)
    mc
    ;;
  showip.rgs)
    local ip="$(getIPAddress)"
    printMsgs "dialog" "Your IP is: ${ip:-(unknown)}\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
    ;;
  #wifi.rgs)
    #wifi-menu
    #;;
  *.rgs)
    archrgs_callModule $no_ext depends
    if fnExists gui_$no_ext; then
      archrgs_callModule $no_ext gui
    else
      archrgs_callModule $no_ext configure
    fi
    ;;
  *.sh)
    cd "$home/Arch-RGS/archrgs_menu" || exit
    sudo -u "$user" bash "$command"
    ;;
  esac
  joy2keyStop
  clear
}

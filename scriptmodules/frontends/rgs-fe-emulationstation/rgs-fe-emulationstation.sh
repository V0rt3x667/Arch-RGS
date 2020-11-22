#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

archrgs_module_id="rgs-fe-emulationstation"
archrgs_module_desc="EmulationStation - Frontend Used by Arch-RGS for Launching Emulators"
archrgs_module_licence="MIT https://raw.githubusercontent.com/RetroPie/EmulationStation/master/LICENSE.md"
archrgs_module_section="core"
archrgs_module_flags="frontend"

function _get_input_cfg_rgs-fe-emulationstation() {
  echo "$configdir/all/emulationstation/es_input.cfg"
}

function _update_hook_rgs-fe-emulationstation() {
  ##MAKE SURE THE INPUT CONFIGURATION SCRIPTS AND LAUNCH SCRIPT ARE ALWAYS UP TO DATE
  if archrgs_isInstalled "$md_idx"; then
    copy_inputscripts_rgs-fe-emulationstation
    install_launch_rgs-fe-emulationstation
  fi
}

function _sort_systems_rgs-fe-emulationstation() {
  local field="$1"
  cp "/etc/emulationstation/es_systems.cfg" "/etc/emulationstation/es_systems.cfg.bak"
  xmlstarlet sel -D -I \
    -t -m "/" -e "systemList" \
    -m "//system" -s A:T:U "$1" -c "." \
    "/etc/emulationstation/es_systems.cfg.bak" >"/etc/emulationstation/es_systems.cfg"
}

function _add_system_rgs-fe-emulationstation() {
  local fullname="$1"
  local name="$2"
  local path="$3"
  local extension="$4"
  local command="$5"
  local platform="$6"
  local theme="$7"
  local conf="/etc/emulationstation/es_systems.cfg"

  mkdir -p "/etc/emulationstation"
  if [[ ! -f "$conf" ]]; then
    echo "<systemList />" >"$conf"
  fi

  cp "$conf" "$conf.bak"
  if [[ $(xmlstarlet sel -t -v "count(/systemList/system[name='$name'])" "$conf") -eq 0 ]]; then
    xmlstarlet ed -L \
      -s "/systemList" -t elem -n "system" -v "" \
      -s "/systemList/system[last()]" -t elem -n "name" -v "$name" \
      -s "/systemList/system[last()]" -t elem -n "fullname" -v "$fullname" \
      -s "/systemList/system[last()]" -t elem -n "path" -v "$path" \
      -s "/systemList/system[last()]" -t elem -n "extension" -v "$extension" \
      -s "/systemList/system[last()]" -t elem -n "command" -v "$command" \
      -s "/systemList/system[last()]" -t elem -n "platform" -v "$platform" \
      -s "/systemList/system[last()]" -t elem -n "theme" -v "$theme" "$conf"
  else
    xmlstarlet ed -L \
      -u "/systemList/system[name='$name']/fullname" -v "$fullname" \
      -u "/systemList/system[name='$name']/path" -v "$path" \
      -u "/systemList/system[name='$name']/extension" -v "$extension" \
      -u "/systemList/system[name='$name']/command" -v "$command" \
      -u "/systemList/system[name='$name']/platform" -v "$platform" \
      -u "/systemList/system[name='$name']/theme" -v "$theme" "$conf"
  fi

  _sort_systems_rgs-fe-emulationstation "name"
}

function _del_system_rgs-fe-emulationstation() {
  local fullname="$1"
  local name="$2"
  if [[ -f /etc/emulationstation/es_systems.cfg ]]; then
    xmlstarlet ed -L -P -d "/systemList/system[name='$name']" /etc/emulationstation/es_systems.cfg
  fi
}

function _add_rom_rgs-fe-emulationstation() {
  local system_name="$1"
  local system_fullname="$2"
  local path="./$3"
  local name="$4"
  local desc="$5"
  local image="$6"
  local config_dir="$configdir/all/emulationstation"

  mkUserDir "$config_dir"
  mkUserDir "$config_dir/gamelists"
  mkUserDir "$config_dir/gamelists/$system_name"

  local config="$config_dir/gamelists/$system_name/gamelist.xml"

  if [[ ! -f "$config" ]]; then
    echo "<gameList />" >"$config"
  fi

  if [[ $(xmlstarlet sel -t -v "count(/gameList/game[path='$path'])" "$config") -eq 0 ]]; then
    xmlstarlet ed -L \
      -s "/gameList" -t elem -n "game" -v "" \
      -s "/gameList/game[last()]" -t elem -n "path" -v "$path" \
      -s "/gameList/game[last()]" -t elem -n "name" -v "$name" \
      -s "/gameList/game[last()]" -t elem -n "desc" -v "$desc" \
      -s "/gameList/game[last()]" -t elem -n "image" -v "$image" "$config"
  else
    xmlstarlet ed -L \
      -u "/gameList/game[name='$name']/path" -v "$path" \
      -u "/gameList/game[name='$name']/name" -v "$name" \
      -u "/gameList/game[name='$name']/desc" -v "$desc" \
      -u "/gameList/game[name='$name']/image" -v "$image" "$config"
  fi
  chown "$user:$user" "$config"
}

function install_bin_rgs-fe-emulationstation() {
  pacmanPkg rgs-fe-emulationstation
}

function remove_rgs-fe-emulationstation() {
  pacmanRemove rgs-fe-emulationstation

  rm -f "/usr/bin/emulationstation"
  rm -rfv "/usr/local/share/icons/Arch-RGS.svg" "/usr/local/share/applications/Arch-RGS.desktop"
}

function init_input_rgs-fe-emulationstation() {
  local es_config
  es_config="$(_get_input_cfg_rgs-fe-emulationstation)"
  
  ##IF THERE IS NO ES CONFIG (OR EMPTY FILE) CREATE IT WITH INITIAL INPUTLIST ELEMENT
  if [[ ! -s "$es_config" ]]; then
    echo "<inputList />" >"$es_config"
  fi

  ##ADD & UPDATE OUR inputconfiguration.sh inputAction
  if [[ $(xmlstarlet sel -t -v "count(/inputList/inputAction[@type='onfinish'])" "$es_config") -eq 0 ]]; then
    xmlstarlet ed -L -S \
      -s "/inputList" -t elem -n "inputActionTMP" -v "" \
      -s "//inputActionTMP" -t attr -n "type" -v "onfinish" \
      -s "//inputActionTMP" -t elem -n "command" -v "$md_inst/scripts/inputconfiguration.sh" \
      -r "//inputActionTMP" -v "inputAction" "$es_config"
  else
    xmlstarlet ed -L \
      -u "/inputList/inputAction[@type='onfinish']/command" -v "$md_inst/scripts/inputconfiguration.sh" "$es_config"
  fi
  chown "$user:$user" "$es_config"
}

function copy_inputscripts_rgs-fe-emulationstation() {
  mkdir -p "$md_inst/scripts"
  cp -r "$md_data/data/"{configscripts,*.sh} "$md_inst/scripts"
  #cp -r "$scriptdir/scriptmodules/$md_type/$md_id/data/"{configscripts,*.sh} "$md_inst/scripts"
  chmod +x "$md_inst/scripts/inputconfiguration.sh"
}

function install_launch_rgs-fe-emulationstation() {
  cat >/usr/bin/emulationstation <<_EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "emulationstation should not be run as root. If you used 'sudo emulationstation' please run without sudo."
    exit 1
fi

##SAVE CURRENT TTY/VT NUMBER FOR USE WITH X SO IT CAN BE LAUNCHED ON THE CORRECT TTY
TTY=\$(tty)
export TTY="\${TTY:8:1}"

clear
tput civis
"$md_inst/emulationstation.sh" "\$@"
  if [[ \$? -eq 139 ]]; then
    dialog --cr-wrap --no-collapse --msgbox "Emulation Station crashed!\n\nIf this is your first boot of Arch-RGS - make sure you are using the correct image for your system.\n\\nCheck your rom file/folder permissions and/or switch back to using carbon theme." 20 60 >/dev/tty
  fi
tput cnorm
_EOF_
  chmod +x /usr/bin/emulationstation
  mkdir -p /usr/local/share/{icons,applications}
  cp "$md_data/data/Arch-RGS.svg" "/usr/local/share/icons"
  #cp "$scriptdir/scriptmodules/$md_type/$md_id/data/Arch-RGS.svg" "/usr/local/share/icons"
  cat >/usr/local/share/applications/Arch-RGS.desktop <<_EOF_
[Desktop Entry]
Type=Application
Exec=gnome-terminal --full-screen --hide-menubar -e emulationstation
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[de_DE]=Arch-RGS
Name=Arch-RGS
Comment[de_DE]=Arch-RGS
Comment=Arch-RGS
Icon=/usr/local/share/icons/Arch-RGS.svg
Categories=Game
_EOF_
}

function clear_input_rgs-fe-emulationstation() {
  rm "$(_get_input_cfg_rgs-fe-emulationstation)"
  init_input_rgs-fe-emulationstation
}

function configure_rgs-fe-emulationstation() {
  ##MOVE THE $home/emulationstation CONFIGURATION DIR AND SYMLINK IT
  moveConfigDir "$home/.emulationstation" "$configdir/all/emulationstation"

  [[ "$md_mode" == "remove" ]] && return

  init_input_rgs-fe-emulationstation

  copy_inputscripts_rgs-fe-emulationstation

  install_launch_rgs-fe-emulationstation

  mkdir -p "/etc/emulationstation"

  ##ENSURE WE HAVE A DEFAULT THEME
  archrgs_callModule esthemes install_theme

  addAutoConf "es_swap_a_b" 0
  addAutoConf "disable" 0
}

function gui_rgs-fe-emulationstation() {
  local es_swap=0
  local disable=0
  local default
  local options

  getAutoConf "es_swap_a_b" && es_swap=1
  getAutoConf "disable" && disable=1

  while true; do
    local options=(1 "Clear/Reset Emulation Station input configuration")

    if [[ "$disable" -eq 0 ]]; then
      options+=(2 "Auto Configuration (Currently: Enabled)")
    else
      options+=(2 "Auto Configuration (Currently: Disabled)")
    fi

    if [[ "$es_swap" -eq 0 ]]; then
      options+=(3 "Swap A/B Buttons in ES (Currently: Default)")
    else
      options+=(3 "Swap A/B Buttons in ES (Currently: Swapped)")
    fi

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Choose an option" 22 76 16)
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break
    default="$choice"

    case "$choice" in
    1)
      if dialog --defaultno --yesno "Are you sure you want to reset the Emulation Station controller configuration ? This will wipe all controller configs for ES and it will prompt to reconfigure on next start" 22 76 >/dev/tty 2>&1; then
        clear_input_rgs-fe-emulationstation
        printMsgs "dialog" "$(_get_input_cfg_rgs-fe-emulationstation) has been reset to default values."
      fi
      ;;
    2)
      disable="$((disable ^ 1))"
      setAutoConf "disable" "$disable"
      ;;
    3)
      es_swap="$((es_swap ^ 1))"
      setAutoConf "es_swap_a_b" "$es_swap"
      local ra_swap="false"
      getAutoConf "es_swap_a_b" && ra_swap="true"
      iniSet "menu_swap_ok_cancel_buttons" "$ra_swap" "$configdir/all/retroarch.cfg"
      printMsgs "dialog" "You will need to reconfigure you controller in Emulation Station for the changes to take effect."
      ;;
    esac
  done
}


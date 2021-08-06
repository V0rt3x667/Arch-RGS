#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-solarus"
archrgs_module_desc="Solarus - Open-source Game Engine for Action-RPGs"
archrgs_module_help="Copy Your Solarus Games to $romdir/solarus"
archrgs_module_licence="GPL3 https://gitlab.com/solarus-games/solarus/raw/dev/license.txt"
archrgs_module_section="emulators"

function _options_cfg_file_rgs-em-solarus() {
  echo "$configdir/solarus/options.cfg"
}

function install_bin_rgs-em-solarus() {
  pacmanPkg rgs-em-solarus
}

function remove_rgs-em-solarus() {
  pacmanRemove rgs-em-solarus
}

function configure_rgs-em-solarus() {
  setConfigRoot ""

  addEmulator 1 "$md_id" "solarus" "$md_inst/solarus.sh %ROM%"
  addSystem "solarus"

  moveConfigDir "$home/.solarus" "$configdir/solarus"

  [[ "$md_mode" == "remove" ]] && return

  mkRomDir "solarus"

  ##Create Launcher for Solarus
  cat > "$md_inst/solarus.sh" << _EOF_
#!/usr/bin/env bash
export ALSOFT_DRIVERS="-jack,"
ARGS=("-cursor-visible=no" "-fullscreen=yes")
[[ -f "$(_options_cfg_file_solarus)" ]] && source "$(_options_cfg_file_solarus)"
[[ -n "\$JOYPAD_DEADZONE" ]] && ARGS+=("-joypad-deadzone=\$JOYPAD_DEADZONE")
[[ -n "\$QUIT_COMBO" ]] && ARGS+=("-quit-combo=\$QUIT_COMBO")
"$md_inst"/bin/solarus-run "\${ARGS[@]}" "\$@"
_EOF_
  chmod +x "$md_inst/solarus.sh"
}

function gui_rgs-em-solarus() {
  local options=()
  local default
  local cmd
  local choice
  local joypad_deadzone
  local quit_combo

  iniConfig "=" "\"" "$(_options_cfg_file_rgs-em-solarus)"

  ##Start the Menu GUI
  default="D"
  while true; do
    ##Read Current Options
    iniGet "JOYPAD_DEADZONE" && joypad_deadzone="$ini_value"
    iniGet "QUIT_COMBO" && quit_combo="$ini_value"
    ##Create Menu Options
    options=(
      D "Set joypad axis deadzone (${joypad_deadzone:-default})"
      Q "Set joypad quit buttons combo (${quit_combo:-unset})"
)
    ##Show Main Menu
    cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Choose an option" 16 60 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    default="$choice"
    case "$choice" in
      D)
        cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter a joypad axis deadzone value between 0-32767, higher is less sensitive (leave BLANK to use engine default)" 10 65)
        choice=$("${cmd[@]}" 2>&1 >/dev/tty)
          if [[ $? -eq 0 ]]; then
            if [[ -n "$choice" ]]; then
              iniSet "JOYPAD_DEADZONE" "$choice"
            else
              iniDel "JOYPAD_DEADZONE"
            fi
          chown "$user:$user" "$(_options_cfg_file_rgs-em-solarus)"
          fi
      ;;
      Q)
        cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter joypad button numbers to use for quitting separated by '+' signs (leave BLANK to unset)\n\nTip: use 'jstest' to find button numbers for your joypad" 12 65)
        choice=$("${cmd[@]}" 2>&1 >/dev/tty)
          if [[ $? -eq 0 ]]; then
            if [[ -n "$choice" ]]; then
              iniSet "QUIT_COMBO" "$choice"
            else
              iniDel "QUIT_COMBO"
            fi
          chown "$user:$user" "$(_options_cfg_file_rgs-em-solarus)"
          fi
      ;;
      *)
        break
      ;;
    esac
  done
}


#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-retroarch"
archrgs_module_desc="RetroArch - Frontend for the Libretro API & Libretro Cores"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/RetroArch/master/COPYING"
archrgs_module_section="core"

function install_bin_rgs-em-retroarch() {
  pacmanPkg rgs-em-retroarch
}

function remove_rgs-em-retroarch() {
  pacmanRemove rgs-em-retroarch
}

function update_shaders_glsl_rgs-em-retroarch() {
  local dir
  dir="$configdir/all/retroarch/shaders/glsl_shaders"
  [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
  gitPullOrClone "$dir" https://github.com/libretro/glsl-shaders.git
  chown -R "$user:$user" "$configdir/all/retroarch/shaders"
}


function update_shaders_slang_rgs-em-retroarch() {
  local dir
  dir="$configdir/all/retroarch/shaders/slang_shaders"
  [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
  gitPullOrClone "$dir" https://github.com/libretro/slang-shaders.git
  chown -R "$user:$user" "$configdir/all/retroarch/shaders"
}

function update_overlay_rgs-em-retroarch() {
  local dir
  dir="$configdir/all/retroarch/overlay"
  [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
  gitPullOrClone "$dir" https://github.com/libretro/common-overlays.git
  chown -R "$user:$user" "$dir"
}

function update_assets_rgs-em-retroarch() {
  local dir
  dir="$configdir/all/retroarch/assets"
  [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
  gitPullOrClone "$dir" https://github.com/libretro/retroarch-assets.git
  chown -R "$user:$user" "$dir"
}

function configure_rgs-em-retroarch() {
  [[ "$md_mode" == "remove" ]] && return

  moveConfigDir "$home/.config/retroarch" "$configdir/all/retroarch"
  moveConfigDir "$configdir/all/retroarch-joypads" "$configdir/all/retroarch/autoconfig"
  moveConfigDir "$md_inst/assets" "$configdir/all/retroarch/assets"
  moveConfigDir "$md_inst/overlays" "$configdir/all/retroarch/overlay"
  moveConfigDir "$md_inst/shader" "$configdir/all/retroarch/shaders"
  moveConfigDir "$md_inst/filters" "$configdir/all/retroarch/filters"

  local config
  config="$(mktemp)"
  cp "$md_inst/etc/retroarch.cfg" "$config"

  ##Query EmulationStation A/B Key Swap Configuration
  local es_swap="false"
  getAutoConf "es_swap_a_b" && es_swap="true"

  ##Configure Default Options
  iniConfig " = " '"' "$config"
  iniSet "cache_directory" "/tmp/retroarch"
  iniSet "system_directory" "$biosdir"
  iniSet "config_save_on_exit" "false"
  iniSet "video_aspect_ratio_auto" "true"
  iniSet "rgui_show_start_screen" "false"
  iniSet "rgui_browser_directory" "$romdir"
  iniSet "video_threaded" "false"
  iniSet "video_font_size" "24"
  iniSet "core_options_path" "$configdir/all/retroarch-core-options.cfg"
  iniSet "global_core_options" "true"
  iniSet "video_fullscreen" "true"

  ##Enable Hotkey ("Select" Button)
  iniSet "input_enable_hotkey" "nul"
  iniSet "input_exit_emulator" "escape"

  ##Configure Default Directories
  iniSet "video_filter_dir" "$md_inst/filters/video"
  iniSet "audio_filter_dir" "$md_inst/filters/audio"
  iniSet "libretro_info_path" "$md_inst/info"
  iniSet "video_shader_dir" "$configdir/all/retroarch/shaders"
  iniSet "overlay_directory" "$configdir/all/retroarch/overlay"
  iniSet "assets_directory" "$configdir/all/retroarch/assets"

  ##Enable & Configure Rewind Feature
  iniSet "rewind_enable" "false"
  iniSet "rewind_buffer_size" "10"
  iniSet "rewind_granularity" "2"
  iniSet "input_rewind" "r"

  ##Enable GPU Screenshots
  iniSet "video_gpu_screenshot" "true"

  ##Enable & Configure Shaders
  iniSet "input_shader_next" "m"
  iniSet "input_shader_prev" "n"

  ##Configure Keyboard Mappings
  iniSet "input_player1_a" "x"
  iniSet "input_player1_b" "z"
  iniSet "input_player1_y" "a"
  iniSet "input_player1_x" "s"
  iniSet "input_player1_start" "enter"
  iniSet "input_player1_select" "rshift"
  iniSet "input_player1_l" "q"
  iniSet "input_player1_r" "w"
  iniSet "input_player1_left" "left"
  iniSet "input_player1_right" "right"
  iniSet "input_player1_up" "up"
  iniSet "input_player1_down" "down"

  ##Input Settings
  iniSet "input_autodetect_enable" "true"
  iniSet "auto_remaps_enable" "true"
  iniSet "input_joypad_driver" "udev"
  iniSet "all_users_control_menu" "true"

  ##Hide Online Updater Menu Options & Restart Option
  iniSet "menu_show_core_updater" "false"
  iniSet "menu_show_online_updater" "false"
  iniSet "menu_show_restart_retroarch" "false"

  ##Disable Unnecessary Menu Tabs
  iniSet "xmb_show_add" "false"
  iniSet "xmb_show_history" "false"
  iniSet "xmb_show_images" "false"
  iniSet "xmb_show_music" "false"

  ##Swap A/B Buttons Based On ES Configuration
  iniSet "menu_swap_ok_cancel_buttons" "$es_swap"

  ##Enable menu_unified_Controls By Default
  iniSet "menu_unified_controls" "true"

  ##Disable 'Press Twice to Quit'
  iniSet "quit_press_twice" "false"

  ##Enable Video Shaders
  iniSet "video_shader_enable" "true"

  copyDefaultConfig "$config" "$configdir/all/retroarch.cfg"
  rm "$config"

  ##Force Menu_Unified_Controls
  _set_config_option_rgs-em-retroarch "menu_unified_controls" "true"

  ##Disable `quit_press_twice` On Existing Configs
  _set_config_option_rgs-em-retroarch "quit_press_twice" "false"

  ##Enable Video Shaders On Existing Configs
  _set_config_option_rgs-em-retroarch "video_shader_enable" "true"

  ##Keep All Core Options In A Single File
  _set_config_option_rgs-em-retroarch "global_core_options" "true"

  ##Remapping Hack For 8bitdo Firmware
  addAutoConf "8bitdo_hack" 0
}

function keyboard_rgs-em-retroarch() {
  if [[ ! -f "$configdir/all/retroarch.cfg" ]]; then
    printMsgs "dialog" "No RetroArch configuration file found at $configdir/all/retroarch.cfg"
    return
  fi
  local input
  local options
  local i=1
  local key=()
  while read -r input; do
    local parts
    parts=("$input")
    key+=("${parts[0]}")
    options+=("${parts[0]}" "$i" 2 "${parts[*]:2}" "$i" 26 16 0)
    ((i++))
  done < <(grep "^[[:space:]]*input_player[0-9]_[a-z]*" "$configdir/all/retroarch.cfg")
  local cmd
  local choice
  cmd=(dialog --backtitle "$__backtitle" --form "RetroArch keyboard configuration" 22 48 16)
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  if [[ -n "$choice" ]]; then
    local value
    local values
    readarray -t values <<<"$choice"
    iniConfig " = " "" "$configdir/all/retroarch.cfg"
    i=0
    for value in "${values[@]}"; do
      iniSet "${key[$i]}" "$value" >/dev/null
      ((i++))
    done
  fi
}

function hotkey_rgs-em-retroarch() {
  iniConfig " = " '"' "$configdir/all/retroarch.cfg"
  local cmd
  local options
  local choice
  cmd=(dialog --backtitle "$__backtitle" --menu "Choose the Desired Hotkey Behaviour" 22 76 16)
  options=(
    1 "Hotkeys Enabled (default)"
    2 "Press ALT to Enable Hotkeys"
    3 "Hotkeys Disabled. Press ESCAPE to Open Retroarch Menu"
  )
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  if [[ -n "$choice" ]]; then
    case "$choice" in
    1)
      iniSet "input_enable_hotkey" "nul"
      iniSet "input_exit_emulator" "escape"
      iniSet "input_menu_toggle" "F1"
      ;;
    2)
      iniSet "input_enable_hotkey" "alt"
      iniSet "input_exit_emulator" "escape"
      iniSet "input_menu_toggle" "F1"
      ;;
    3)
      iniSet "input_enable_hotkey" "escape"
      iniSet "input_exit_emulator" "nul"
      iniSet "input_menu_toggle" "escape"
      ;;
    esac
  fi
}

function gui_rgs-em-retroarch() {
  while true; do
    local names
    local dirs
    local options=()
    local name
    local dir
    local i=1
    names=(shaders_glsl shaders_slang overlay assets)
    dirs=(shaders/glsl_shaders shaders/slang_shaders overlay assets)
    for name in "${names[@]}"; do
      if [[ -d "$configdir/all/retroarch/${dirs[i-1]}/.git" ]]; then
        options+=("$i" "Manage $name (installed)")
      else
        options+=("$i" "Manage $name (not installed)")
      fi
      ((i++))
    done
    options+=(
      5 "Configure Keyboard For Use With Retroarch"
      6 "Configure Keyboard Hotkey Behaviour For Retroarch"
    )
    local cmd
    local choice
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
    1 | 2 | 3 | 4)
      name="${names[choice-1]}"
      dir="${dirs[choice-1]}"
      options=(1 "Install/Update $name" 2 "Uninstall $name")
      cmd=(dialog --backtitle "$__backtitle" --menu "Choose An Option For $dir" 12 40 06)
      choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
      case "$choice" in
      1)
        "update_${name}_rgs-em-retroarch"
        ;;
      2)
        rm -rf "$configdir/all/retroarch/$dir"
        ;;
      *)
        continue
        ;;
      esac
      ;;
    5)
      keyboard_rgs-em-retroarch
      ;;
    6)
      hotkey_rgs-em-retroarch
      ;;
    *)
      break
      ;;
    esac
  done
}

##Adds A Retroarch Global Config Option In $configdir/all/retroarch.cfg
function _set_config_option_rgs-em-retroarch() {
  local option
  local value
  option="$1"
  value="$2"
  iniConfig " = " "\"" "$configdir/all/retroarch.cfg"
  iniGet "$option"
  if [[ -z "$ini_value" ]]; then
    iniSet "$option" "$value"
  fi
}


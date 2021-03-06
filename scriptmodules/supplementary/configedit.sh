#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="configedit"
archrgs_module_desc="Edit Arch-RGS & RetroArch Configurations"
archrgs_module_section="config"

function _joypad_index_configedit() {
  local mode="$1"
  local value="$2"

  while true; do
    local players=()
    local player
    for player in 1 2 3 4; do
      iniGet "input_player${player}_joypad_index"
      if [[ -n "$ini_value" ]]; then
        players+=("$ini_value")
      else
        players+=("unset")
      fi
    done

    case "$mode" in
    get)
      echo "${players[@]}"
      return
      ;;
    set)
      local dev
      local devs_name=()
      local path
      local paths=()

      ##GET JOYSTICK DEVICE PATHS
      while read -r dev; do
        if udevadm info --name=$dev | grep -q "ID_INPUT_JOYSTICK=1"; then
          paths+=("$(udevadm info --name=$dev --query=name)")
        fi
      done < <(find /dev/input -name "js*")

      if [[ "${#paths[@]}" -gt 0 ]]; then
        ##SORT BY PATH
        IFS=$'\n'
        while read -r path; do
          devs_name+=("$(cat /sys/class/$path/device/name)")
        done < <(sort <<<"${paths[*]}")
        unset IFS
      fi

      local options=()
      local i
      local value
      local joypad

      for i in 1 2 3 4; do
        player="${players[$i-1]}"
        value="$player"
        joypad="${devs_name[$player]}"
        [[ -z "$joypad" ]] && joypad="not connected"
        [[ "$player" != "unset" ]] && value+=" ($joypad)"
        options+=("$i" "$value")
      done

      local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose a player to adjust" 22 76 16)
      local choice
      choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
      [[ -z "$choice" ]] && return
      player="$choice"
      options=(U Unset)
      local i=0

      for dev in "${devs_name[@]}"; do
        options+=("$i" "$dev")
        ((i++))
      done

      local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose a Gamepad" 22 76 16)
      local choice
      choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
      [[ -z "$choice" ]] && continue
      case "$choice" in
      U)
        iniUnset "input_player${player}_joypad_index"
        ;;
      *)
        iniSet "input_player${player}_joypad_index" "$choice"
        ;;
      esac
      ;;
    esac
  done
}

function basic_configedit() {
  local config="$1"

  local ini_options=(
    'video_smooth true false'
    'aspect_ratio_index _id_ 4:3 16:9 16:10 16:15 21:9 1:1 2:1 3:2 3:4 4:1 4:4 5:4 6:5 7:9 8:3 8:7 19:12 19:14 30:17 32:9 config square core custom'
    'video_shader_enable true false'
    "video_shader _file_ *.*p $rootdir/emulators/rgs-em-retroarch/shader"
    'input_overlay_enable true false'
    "input_overlay _file_ *.cfg $rootdir/emulators/rgs-em-retroarch/overlays"
    '_function_ _joypad_index_configedit'
    'input_player1_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player2_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player3_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player4_analog_dpad_mode _id_ disabled left-stick right-stick'
  )

  local ini_titles=(
    'Video Smoothing'
    'Aspect Ratio'
    'Video Shader Enable'
    'Video Shader File'
    'Overlay Enable'
    'Overlay File'
    'Choose joypad order'
    'Player 1 - use analogue stick as d-pad'
    'Player 2 - use analogue stick as d-pad'
    'Player 3 - use analogue stick as d-pad'
    'Player 4 - use analogue stick as d-pad'
  )

  local ini_descs=(
    'Smoothens picture with bilinear filtering. Should be disabled if using pixel shaders.'
    'Aspect ratio to use (default unset - will use core aspect if video_aspect_ratio_auto is true)'
    'Load video_shader on startup. Other shaders can still be loaded later in runtime.'
    'Video shader to use (default none)'
    'Load input overlay on startup. Other overlays can still be loaded later in runtime.'
    'Input overlay to use (default none)'
    'Manual selection of joypad order'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
  )
  iniFileEditor " = " '"' "$config"
}

function advanced_configedit() {
  local config="$1"
  local audio_opts="alsa alsathread sdl2 pulse"
  local ini_options=(
    'video_smooth true false'
    'aspect_ratio_index _id_ 4:3 16:9 16:10 16:15 21:9 1:1 2:1 3:2 3:4 4:1 4:4 5:4 6:5 7:9 8:3 8:7 19:12 19:14 30:17 32:9 config square core custom'
    'video_shader_enable true false'
    "video_shader _file_ *.*p $rootdir/emulators/rgs-em-retroarch/shader"
    'input_overlay_enable true false'
    "input_overlay _file_ *.cfg $rootdir/emulators/rgs-em-retroarch/overlays"
    "audio_driver $audio_opts"
    'video_driver gl glcore sdl2 vulkan'
    'menu_driver ozone rgui xmb'
    'video_fullscreen_x _string_'
    'video_fullscreen_y _string_'
    'video_frame_delay _string_'
    'video_threaded true false'
    'video_force_aspect true false'
    'video_scale_integer true false'
    'video_aspect_ratio_auto true false'
    'video_aspect_ratio _string_'
    'video_allow_rotate true false'
    'video_rotation 0 1 2 3'
    'custom_viewport_width _string_'
    'custom_viewport_height _string_'
    'custom_viewport_x _string_'
    'custom_viewport_y _string_'
    'video_font_size _string_'
    'fps_show true false'
    'input_overlay_opacity _string_'
    'input_overlay_scale _string_'
    'input_joypad_driver linuxraw sdl2 udev'
    'game_specific_options true false'
    'input_player1_joypad_index _string_'
    'input_player2_joypad_index _string_'
    'input_player3_joypad_index _string_'
    'input_player4_joypad_index _string_'
    'input_player5_joypad_index _string_'
    'input_player6_joypad_index _string_'
    'input_player7_joypad_index _string_'
    'input_player8_joypad_index _string_'
    'input_player1_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player2_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player3_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player4_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player5_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player6_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player7_analog_dpad_mode _id_ disabled left-stick right-stick'
    'input_player8_analog_dpad_mode _id_ disabled left-stick right-stick'
  )

  local ini_descs=(
    'Smoothens picture with bilinear filtering. Should be disabled if using pixel shaders.'
    'Aspect ratio to use (default unset - will use core aspect if video_aspect_ratio_auto is true)'
    'Load video_shader on startup. Other shaders can still be loaded later in runtime.'
    'Video shader to use (default none)'
    'Load input overlay on startup. Other overlays can still be loaded later in runtime.'
    'Input overlay to use (default none)'
    'Audio driver to use (default is pulse)'
    'Video driver to use (default is gl)'
    'Menu driver to use'
    'Fullscreen x resolution. Resolution of 0 uses the resolution of the desktop. (defaults to 0 if unset)'
    'Fullscreen y resolution. Resolution of 0 uses the resolution of the desktop. (defaults to 0 if unset)'
    'Sets how many milliseconds to delay after VSync before running the core. Can reduce latency at cost of higher risk of stuttering. Maximum is 15'
    'Use threaded video driver. Using this might improve performance at possible cost of latency and more video stuttering.'
    'Forces rendering area to stay equal to content aspect ratio or as defined in video_aspect_ratio.'
    'Only scales video in integer steps. The base size depends on system-reported geometry and aspect ratio. If video_force_aspect is not set, X/Y will be integer scaled independently.'
    'If this is true and video_aspect_ratio or video_aspect_ratio_index is not set, aspect ratio is decided by libretro implementation. If this is false, 1:1 PAR will always be assumed if video_aspect_ratio or  video_aspect_ratio_index is not set.'
    'A floating point value for video aspect ratio (width / height). If this is not set, aspect ratio is assumed to be automatic. Behavior then is defined by video_aspect_ratio_auto.'
    'Allows libretro cores to set rotation modes. Setting this to false will honor, but ignore this request. This is useful for vertically oriented content where one manually rotates the monitor. (defaults to true)'
    'Forces a certain rotation of the screen. The rotation is added to rotations which the libretro core sets (see video_allow_rotate). The angle is <value> * 90 degrees counter-clockwise.'
    'Viewport resolution.'
    'Viewport resolution.'
    'Viewport position x.'
    'Viewport position y.'
    'Size of the OSD font.'
    'Show current frames per second.'
    'Opacity of overlay. Float value 1.000000.'
    'Scale of overlay. Float value 1.000000.'
    'Input joypad driver to use (default is udev)'
    'Game specific core options in retroarch-core-options.cfg, rather than for all games via that core.'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Manual selection of joypad order'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
    'Allow analogue sticks to be used as a d-pad - 0 = disabled, 1 = left stick, 2 = right stick'
  )
  iniFileEditor " = " '"' "$config"
}

function choose_config_configedit() {
  local path="$1"
  local include="$2"
  local exclude="$3"
  local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Which configuration would you like to edit" 22 76 16)
  local configs=()
  local options=()
  local config
  local i=0

  while read -r config; do
    config=${config//$path\//}
    configs+=("$config")
    options+=("$i" "$config")
    ((i++))
  done < <(find "$path" -type f -regex "$include" ! -regex "$exclude" ! -regex ".*/downloaded_images/.*" | sort)

  local choice
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  if [[ -n "$choice" ]]; then
    echo "${configs[choice]}"
  fi
}

function basic_menu_configedit() {
  while true; do
    local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Which platform do you want to adjust" 22 76 16)
    local configs=()
    local options=()
    local config
    local dir
    local desc
    local i=0

    while read -r config; do
      configs+=("$config")
      dir=${config%/*}
      dir=${dir//$configdir\//}
      if [[ "$dir" == "all" ]]; then
        desc="Configure default options for all libretro emulators"
      else
        desc="Configure additional options for $dir"
      fi
      options+=("$i" "$desc")
      ((i++))
    done < <(find "$configdir" -type f -regex ".*/retroarch.cfg" | sort)

    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
      basic_configedit "${configs[choice]}"
    else
      break
    fi
  done
}

function advanced_menu_configedit() {
  while true; do
    local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose an option" 22 76 16)
    local options=(
      1 "Configure Libretro options"
      2 "Manually edit RetroArch configurations"
      3 "Manually edit global configs"
      4 "Manually edit non RetroArch configurations"
      5 "Manually edit all configurations"
    )
    local choice
    local file="-"
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
      local ra_exclude='.*/all/retroarch/\(assets\|shaders\)/.*'
      while [[ -n "$file" ]]; do
        case "$choice" in
        1)
          file=$(choose_config_configedit "$configdir" ".*/retroarch.cfg")
          advanced_configedit "$configdir/$file" 2
          ;;
        2)
          file=$(choose_config_configedit "$configdir" ".*/retroarch.*" "$ra_exclude")
          editFile "$configdir/$file"
          ;;
        3)
          file=$(choose_config_configedit "$configdir" ".*/all/.*" "$ra_exclude")
          editFile "$configdir/$file"
          ;;
        4)
          file=$(choose_config_configedit "$configdir" ".*" ".*retroarch.*")
          editFile "$configdir/$file"
          ;;
        5)
          file=$(choose_config_configedit "$configdir" ".*" "$ra_exclude")
          editFile "$configdir/$file"
          ;;
        esac
      done
    else
      break
    fi
  done
}

function gui_configedit() {
  while true; do
    local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Exit" --menu "Choose an option" 22 76 16)
    local options
    local choice
    local file="-"
    options=(
      1 "Configure basic libretro emulator options"
      2 "Advanced Configuration"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
      case $choice in
      1)
        basic_menu_configedit
        ;;
      2)
        advanced_menu_configedit
        ;;
      esac
    else
      break
    fi
  done
}


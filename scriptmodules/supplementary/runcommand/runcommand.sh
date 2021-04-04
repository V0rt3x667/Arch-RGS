#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

## @file supplementary/runcommand/runcommand.sh
## @brief runcommand launching script
## @copyright GPLv3
## @details
## @par Usage
##
## `runcommand.sh VIDEO_MODE COMMAND SAVE_NAME`
##
## or
##
## `runcommand.sh VIDEO_MODE _SYS_/_PORT_ SYSTEM ROM`
##
## Video mode switching is supported on X11.
##
## Automatic video mode selection:
##
## * VIDEO_MODE = 0: use the current video mode
##
## Manual video mode selection (X11):
##
## * VIDEO_MODE = "OUTPUT:MODEID": set video mode to connected output name and mode index
##
## If `_SYS_` or `_PORT_` is provided for the second parameter, the commandline
## will be extracted from `/opt/archrgs/configs/SYSTEM/emulators.cfg` with
## `%ROM%` `%BASENAME%` being replaced with the ROM parameter. This is the
## default mode used when launching in archrgs so the user can switch emulator
## used as well as other options from the runcommand GUI.
##
## If SAVE_NAME is included, that is used for loading and saving of video output
## modes. If omitted, the binary name is used as a key for the loading and saving.
## The savename is also displayed in the video output menu (detailed below), so for our purposes
## we send the emulator module id, which is somewhat descriptive yet short.
##
## On launch this script waits for 2 second for a key or joystick press. If
## pressed the GUI is shown, where a user can set video modes, default emulators
## and other options (depending what is being launched).

ROOTDIR="/opt/archrgs"
CONFIGDIR="$ROOTDIR/configs"
LOG="/dev/shm/runcommand.log"

RUNCOMMAND_CONF="$CONFIGDIR/all/runcommand.cfg"
VIDEO_CONF="$CONFIGDIR/all/videomodes.cfg"
EMU_CONF="$CONFIGDIR/all/emulators.cfg"
RETRONETPLAY_CONF="$CONFIGDIR/all/retronetplay.cfg"

##MODESETTING TOOLS
XRANDR="xrandr"

source "$ROOTDIR/lib/inifuncs.sh"

function get_config() {
  if [[ -f "$RUNCOMMAND_CONF" ]]; then
    iniConfig " = " '"' "$RUNCOMMAND_CONF"
    iniGet "use_art"
    USE_ART="$ini_value"
    iniGet "disable_joystick"
    DISABLE_JOYSTICK="$ini_value"
    iniGet "disable_menu"
    DISABLE_MENU="$ini_value"
    iniGet "image_delay"
    IMAGE_DELAY="$ini_value"
    [[ -z "$IMAGE_DELAY" ]] && IMAGE_DELAY=2
  fi

  if [[ -n "$DISPLAY" ]] && $XRANDR &>/dev/null; then
    HAS_MODESET="x11"
  fi
}

function start_joy2key() {
  [[ "$DISABLE_JOYSTICK" -eq 1 ]] && return

  ##GET THE FIRST JOYSTICK DEVICE (IF NOT ALREADY SET)
  if [[ -c "$__joy2key_dev" ]]; then
    JOY2KEY_DEV="$__joy2key_dev"
  else
    JOY2KEY_DEV="/dev/input/jsX"
  fi
  ##IF JOY2KEY.PY IS INSTALLED RUN IT WITH CURSOR KEYS FOR AXIS, AND ENTER + TAB FOR BUTTONS 0 AND 1
  if [[ -f "$ROOTDIR/supplementary/runcommand/joy2key.py" && -n "$JOY2KEY_DEV" ]] && ! pgrep -f joy2key.py >/dev/null; then
    ##CALL joy2key.py: ARGUMENTS ARE CURSES CAPABILITY NAMES OR HEX VALUES STARTING WITH '0x'
    ##SEE: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
    "$ROOTDIR/supplementary/runcommand/joy2key.py" "$JOY2KEY_DEV" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09
    JOY2KEY_PID=$(pgrep -f joy2key.py)
    ##ENSURE COHERENCY BETWEEN ON-SCREEN PROMPTS AND ACTUAL BUTTON MAPPING FUNCTIONALITY
    sleep 0.3
  fi
}

function stop_joy2key() {
  if [[ -n "$JOY2KEY_PID" ]]; then
    kill "$JOY2KEY_PID"
    JOY2KEY_PID=""
    sleep 1
  fi
}

function get_params() {
  MODE_REQ="$1"
  COMMAND="$2"
  [[ -z "$MODE_REQ" || -z "$COMMAND" ]] && return 1
  CONSOLE_OUT=0

  ##IF THE COMMAND IS _SYS_, OR _PORT_ ARG 3 SHOULD BE SYSTEM NAME, AND ARG 4 ROM/GAME, AND WE LOOK UP THE CONFIGURED SYSTEM FOR THAT COMBINATION
  if [[ "$COMMAND" == "_SYS_" || "$COMMAND" == "_PORT_" ]]; then
    ##IF THE ROM IS ACTUALLY A SPECIAL +Start System.sh SCRIPT, WE SHOULD LAUNCH THE SCRIPT DIRECTLY.
    if [[ "$4" =~ \/\+Start\ (.+)\.sh$ ]]; then
      ##EXTRACT EMULATOR FROM THE NAME (AND LOWERCASE IT)
      EMULATOR=${BASH_REMATCH[1],,}
      IS_SYS=0
      COMMAND="bash \"$4\""
      SYSTEM="$3"
      [[ -z "$SYSTEM" ]] && return 1
    else
      IS_SYS=1
      SYSTEM="$3"
      ROM="$4"
      ROM_BN_EXT="${ROM##*/}"
      ROM_BN="${ROM_BN_EXT%.*}"
      if [[ "$COMMAND" == "_PORT_" ]]; then
        CONF_ROOT="$CONFIGDIR/ports/$SYSTEM"
        EMU_SYS_CONF="$CONF_ROOT/emulators.cfg"
        IS_PORT=1
      else
        CONF_ROOT="$CONFIGDIR/$SYSTEM"
        EMU_SYS_CONF="$CONF_ROOT/emulators.cfg"
        IS_PORT=0
      fi
      SYS_SAVE_ROM_OLD="a$(echo "$SYSTEM$ROM" | md5sum | cut -d" " -f1)"
      SYS_SAVE_ROM="$(clean_name "${SYSTEM}_${ROM_BN}")"
      [[ -z "$SYSTEM" ]] && return 1
      get_sys_command
    fi
  else
    IS_SYS=0
    CONSOLE_OUT=1
    EMULATOR="$3"
    ##IF WE HAVE AN EMULATOR NAME (SUCH AS MODULE_ID) WE USE THAT FOR STORING/LOADING PARAMETERS FOR VIDEO OUTPUT
    ##IF THE PARAMETER IS EMPTY WE USE THE NAME OF THE BINARY
    [[ -z "$EMULATOR" ]] && EMULATOR="${COMMAND/% */}"
  fi
  NETPLAY=0
  return 0
}

function clean_name() {
  local name="$1"
  name="${name//\//_}"
  name="${name//[^a-zA-Z0-9_\-]/}"
  echo "$name"
}

function set_save_vars() {
  ##CONVERT EMULATOR NAME / BINARY TO A NAMES USABLE AS VARIABLES IN OUR CONFIG FILES
  SAVE_EMU="$(clean_name "$EMULATOR")"
  SAVE_ROM_OLD=r$(echo "$COMMAND" | md5sum | cut -d" " -f1)
  if [[ "$IS_SYS" -eq 1 ]]; then
    SAVE_ROM="${SAVE_EMU}_$(clean_name "$ROM_BN")"
  else
    SAVE_ROM="$SAVE_EMU"
  fi
}


function get_all_x11_modes() {
  declare -Ag MODE
  local id
  local info
  local line
  local verbose_info=()
  local output
  output="$($XRANDR --verbose | grep " connected" | awk '{ print $1 }')"

  while read -r line; do
    ##SCAN FOR LINE THAT CONTAINS BRACKETED MODE ID
    id="$(echo "$line" | awk '{ print $2 }' | grep -o "(0x[a-f0-9]\{1,\})")"
    if [[ -n "$id" ]]; then
      ##STRIP BRACKETS FROM MODE ID
      id="$(echo ${id:1:-1})"
      ##EXTRACT EXTENDED DETAILS
      verbose_info=($(echo "$line" | awk '{ for (i=3; i<=NF; ++i) print $i }'))
      ##EXTRACT X/Y RESOLUTION, VERTICAL REFRESH RATE AND APPEND DETAILS
      read -r line
      info="$(echo "$line" | awk '{ print $3 }')"
      read -r line
      info+="x$(echo "$line" | awk '{ print $3 }') @ $(echo "$line" | awk '{ print $NF }') ("${verbose_info[*]}")"
      ##POPULATE RESOLUTION INTO ARRAYS
      MODE_ID+=($output:$id)
      MODE[$output:$id]="$info"
    fi
  done < <($XRANDR --verbose)
}


function get_x11_mode_info() {
  local mode_id=(${1/:/ })
  local mode_info=()
  local status

  if [[ -z "$mode_id" ]]; then
    ##DETERMINE CURRENT OUTPUT
    mode_id[0]="$($XRANDR --verbose | awk '/ connected/ { print $1;exit }')"
    ##DETERMINE CURRENT MODE ID & STRIP BRACKETS
    mode_id[1]="$($XRANDR --verbose | awk '/ connected/ {print;exit}' | grep -o "(0x[a-f0-9]\{1,\})")"
    mode_id[1]="$(echo ${mode_id[1]:1:-1})"
  fi

  ##MODE TYPE CORRESPONDS TO THE CURRENTLY CONNECTED OUTPUT NAME
  mode_info[0]="${mode_id[0]}"

  ##GET MODE ID
  mode_info[1]="${mode_id[1]}"

  ##GET STATUS LINE AND SPLIT RESOLUTION
  status=(${MODE[${mode_id[0]}:${mode_id[1]}]/x/ })

  ##GET RESOLUTION
  mode_info[2]="${status[0]}"
  mode_info[3]="${status[1]}"

  ##ASPECT RATIO CANNOT BE DETERMINED FOR X11
  mode_info[4]="n/a"

  ##GET REFRESH RATE (STRIPPING HZ, ROUNDED TO INTEGER)
  mode_info[5]="$(LC_NUMERIC=C printf '%.0f\n' ${status[3]::-2})"

  echo "${mode_info[@]}"
}

function default_process() {
  local config="$1"
  local mode="$2"
  local key="$3"
  local value="$4"

  iniConfig " = " '"' "$config"
  case "$mode" in
  get)
    iniGet "$key"
    echo "$ini_value"
    ;;
  set)
    iniSet "$key" "$value"
    ;;
  del)
    iniDel "$key"
    ;;
  esac
}

function default_mode() {
  local mode="$1"
  local type="$2"
  local value="$3"
  local key

  case "$type" in
  vid_emu)
    key="$SAVE_EMU"
    ;;
  vid_rom_old)
    key="$SAVE_ROM_OLD"
    ;;
  vid_rom)
    key="$SAVE_ROM"
    ;;
  esac
  default_process "$VIDEO_CONF" "$mode" "$key" "$value"
}

function default_emulator() {
  local mode="$1"
  local type="$2"
  local value="$3"
  local key
  local config="$EMU_SYS_CONF"

  case "$type" in
  emu_sys)
    key="default"
    ;;
  emu_cmd)
    key="$EMULATOR"
    ;;
  emu_rom_old)
    key="$SYS_SAVE_ROM_OLD"
    config="$EMU_CONF"
    ;;
  emu_rom)
    key="$SYS_SAVE_ROM"
    config="$EMU_CONF"
    ;;
  esac
  default_process "$config" "$mode" "$key" "$value"
}

function load_mode_defaults() {
  local separator=":"
  local temp
  MODE_ORIG=()

  if [[ -n "$HAS_MODESET" ]]; then
    ##POPULATE AVAILABLE MODES
    [[ -z "$MODE_ID" ]] && get_all_${HAS_MODESET}_modes

    ##GET CURRENT MODE / ASPECT RATIO
    MODE_ORIG=($(get_${HAS_MODESET}_mode_info))
    MODE_CUR=("${MODE_ORIG[@]}")
    MODE_ORIG_ID="${MODE_ORIG[0]}${separator}${MODE_ORIG[1]}"

    if [[ "$MODE_REQ" == "0" ]]; then
      MODE_REQ_ID="$MODE_ORIG_ID"
    else
      MODE_REQ_ID="$MODE_REQ"
    fi
  fi
  local mode
  if [[ -f "$VIDEO_CONF" ]]; then
    ##LOAD DEFAULT VIDEO MODE FOR EMULATOR / ROM
    mode="$(default_mode get vid_emu)"
    [[ -n "$mode" ]] && MODE_REQ_ID="$mode"

    ##GET DEFAULT MODE FOR SYSTEM + ROM COMBINATION
    ##TRY THE OLD KEY FIRST AND CONVERT TO THE NEW KEY IF FOUND
    mode="$(default_mode get vid_rom_old)"
    if [[ -n "$mode" ]]; then
      default_mode del vid_rom_old
      default_mode set vid_rom "$mode"
      MODE_REQ_ID="$mode"
    else
      mode="$(default_mode get vid_rom)"
      [[ -n "$mode" ]] && MODE_REQ_ID="$mode"
    fi
  fi
}

function main_menu() {
  local save
  local cmd
  local choice
  local user_menu=0
  [[ -d "$CONFIGDIR/all/runcommand-menu" && -n "$(find "$CONFIGDIR/all/runcommand-menu" -maxdepth 1 -name "*.sh")" ]] && user_menu=1
  [[ -z "$ROM_BN" ]] && ROM_BN="game/rom"
  [[ -z "$SYSTEM" ]] && SYSTEM="emulator/port"

  while true; do
    local options=()
    if [[ "$IS_SYS" -eq 1 ]]; then
      local emu_sys
      local emu_rom
      emu_sys="$(default_emulator get emu_sys)"
      emu_rom="$(default_emulator get emu_rom)"
      options+=(
        1 "Select default emulator for $SYSTEM ($emu_sys)"
        2 "Select emulator for ROM ($emu_rom)"
      )
      [[ -n "$emu_rom" ]] && options+=(3 "Remove emulator choice for ROM")
    fi

    if [[ -n "$HAS_MODESET" ]]; then
      local vid_emu
      local vid_rom
      vid_emu="$(default_mode get vid_emu)"
      vid_rom="$(default_mode get vid_rom)"
      options+=(
        4 "Select default video mode for $EMULATOR ($vid_emu)"
        5 "Select video mode for $EMULATOR + rom ($vid_rom)"
      )
      [[ -n "$vid_emu" ]] && options+=(6 "Remove video mode choice for $EMULATOR")
      [[ -n "$vid_rom" ]] && options+=(7 "Remove video mode choice for $EMULATOR + ROM")
    fi

    if [[ "$EMULATOR" == rgs-lr-* ]]; then
      options+=(8 "Edit custom RetroArch config for this ROM")
    fi

    options+=(X "Launch")

    if [[ "$EMULATOR" == rgs-lr-* ]]; then
      options+=(L "Launch with verbose logging")
      options+=(Z "Launch with netplay enabled")
    fi

    if [[ "$user_menu" -eq 1 ]]; then
      options+=(U "User Menu")
    fi

    options+=(Q "Exit (without launching)")

    local temp_mode
    if [[ -n "$HAS_MODESET" ]]; then
      temp_mode="${MODE[$MODE_REQ_ID]}"
    else
      temp_mode="n/a"
    fi
    cmd=(dialog --nocancel --menu "System: $SYSTEM\nEmulator: $EMULATOR\nVideo Mode: $temp_mode\nROM: $ROM_BN" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
    1)
      choose_emulator "emu_sys" "$emu_sys"
      ;;
    2)
      choose_emulator "emu_rom" "$emu_rom"
      ;;
    3)
      default_emulator "del" "emu_rom"
      get_sys_command
      set_save_vars
      load_mode_defaults
      ;;
    4)
      choose_mode "vid_emu" "$vid_emu"
      ;;
    5)
      choose_mode "vid_rom" "$vid_rom"
      ;;
    6)
      default_mode "del" "vid_emu"
      load_mode_defaults
      ;;
    7)
      default_mode "del" "vid_rom"
      load_mode_defaults
      ;;
    8)
      touch "$ROM.cfg"
      cmd=(dialog --editbox "$ROM.cfg" 22 76)
      choice=$("${cmd[@]}" 2>&1 >/dev/tty)
      [[ -n "$choice" ]] && echo "$choice" >"$ROM.cfg"
      [[ ! -s "$ROM.cfg" ]] && rm "$ROM.cfg"
      ;;
    Z)
      NETPLAY=1
      break
      ;;
    X)
      return 0
      ;;
    L)
      COMMAND+=" --verbose"
      return 0
      ;;
    U)
      user_menu
      local ret="$?"
      [[ "$ret" -eq 1 ]] && return 1
      [[ "$ret" -eq 2 ]] && return 0
      ;;
    Q)
      return 1
      ;;
    esac
  done
  return 0
}

function choose_mode() {
  local mode="$1"
  local default="$2"

  local options=()
  local key
  for key in "${MODE_ID[@]}"; do
    options+=("$key" "${MODE[$key]}")
  done
  local cmd=(dialog --default-item "$default" --menu "Choose video output mode" 22 76 16)
  local choice
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  [[ -z "$choice" ]] && return

  default_mode set "$mode" "$choice"
  load_mode_defaults
}

function choose_emulator() {
  local mode="$1"
  local default="$2"
  local cancel="$3"
  local default
  local default_id
  local options=()
  local i=1

  while read -r line; do
    ##CONVERT KEY=VALUE TO ARRAY
    local line=(${line/=/ })
    local id=${line[0]}
    [[ "$id" == "default" ]] && continue
    local apps[$i]="$id"
    if [[ "$id" == "$default" ]]; then
      default_id="$i"
    fi
    options+=($i "$id")
    ((i++))
  done < <(sort "$EMU_SYS_CONF")

  if [[ -z "${options[*]}" ]]; then
    dialog --msgbox "No emulator options found for $SYSTEM - Do you have a valid $EMU_SYS_CONF ?" 20 60 >/dev/tty
    stop_joy2key
    exit 1
  fi

  local cmd=(dialog $cancel --default-item "$default_id" --menu "Choose default emulator" 22 76 16)
  local choice
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  [[ -z "$choice" ]] && return

  default_emulator set "$mode" "${apps[$choice]}"
  get_sys_command
  set_save_vars
  load_mode_defaults
}

function user_menu() {
  local default
  local options=()
  local script
  local i=1

  while read -r script; do
    script="${script##*/}"
    script="${script%.*}"
    options+=($i "$script")
    ((i++))
  done < <(find "$CONFIGDIR/all/runcommand-menu" -type f -name "*.sh" | sort)

  local default
  local cmd
  local choice
  local ret

  while true; do
    cmd=(dialog --default-item "$default" --cancel-label "Back" --menu "Choose option" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return 0
    default="$choice"
    script="runcommand-menu/${options[choice*2-1]}.sh"
    user_script "$script"
    ret="$?"
    [[ "$ret" -eq 1 || "$ret" -eq 2 ]] && return "$ret"
  done
}

function build_xinitrc() {
  local mode="$1"
  local xinitrc="/dev/shm/archrgs_xinitrc"

  case "$mode" in
  clear)
    rm -rf "$xinitrc"
    ;;
  build)
    echo "#!/bin/bash" >"$xinitrc"
    ##DO MODESETTING (IF SUPPORTED)
    if [[ -n "$HAS_MODESET" ]]; then
      cat >>"$xinitrc" <<_EOF_
XRANDR_OUTPUT="\$($XRANDR --verbose | grep " connected" | awk '{ print \$1 }')"
$XRANDR --output \$XRANDR_OUTPUT --mode ${MODE_CUR[2]}x${MODE_CUR[3]} --refresh ${MODE_CUR[5]}
echo "Set mode ${MODE_CUR[2]}x${MODE_CUR[3]}@${MODE_CUR[5]}Hz on \$XRANDR_OUTPUT"
_EOF_
    fi

    ##ECHO COMMAND LINE FOR RUNCOMMAND LOG
    cat >>"$xinitrc" <<_EOF_
echo -e "\nExecuting (via xinit): "${COMMAND//\$/\\\$}"\n"
${COMMAND//\$/\\\$}
_EOF_
    chmod +x "$xinitrc"

    ##REWRITE COMMAND TO LAUNCH OUR XINIT SCRIPT (IF NOT STARTX)
    if ! [[ "$COMMAND" =~ ^startx ]]; then
      COMMAND="xinit $xinitrc"
    fi

    ##WORKAROUND FOR LAUNCHING XSERVER ON CORRECT/USER OWNED TTY
    ##SEE https://github.com/RetroPie/RetroPie-Setup/issues/1805
    ##IF NO TTY ENVIRONMENT VARIABLE IS SET, TRY AND GET IT - EG IF LAUNCHING A PORTS SCRIPT OR RUNCOMMAND MANUALLY
    if [[ -z "$TTY" ]]; then
      TTY=$(tty)
      TTY=${TTY:8:1}
    fi

    ##IF WE MANAGED TO GET THE CURRENT TTY THEN TRY AND USE IT
    if [[ -n "$TTY" ]]; then
      COMMAND="$COMMAND -- vt$TTY -keeptty"
    fi
    ;;
  esac
}

function mode_switch() {
  local command_prefix
  local separator=":"
  local mode_id=(${1/${separator}/ })

  ##IF THE REQUESTED MODE IS THE SAME AS THE CURRENT MODE, DON'T SWITCH
  [[ "${mode_id[*]}" == "${MODE_CUR[0]} ${MODE_CUR[1]}" ]] && return 1

  if [[ "$HAS_MODESET" == "x11" ]]; then
    ##QUERY THE TARGET RESOLUTION
    MODE_CUR=($(get_${HAS_MODESET}_mode_info "${mode_id[*]}"))
    ##SET TARGET RESOLUTION
    $XRANDR --output "${MODE_CUR[0]}" --mode "${MODE_CUR[1]}"
    [[ "$?" -eq 0 ]] && return 0
  fi
  return 1
}

function retroarch_append_config() {
  local conf="/dev/shm/retroarch.cfg"
  local dim

  ##ONLY FOR RETROARCH EMULATORS
  [[ "$EMULATOR" != rgs-lr-* ]] && return

  ##MAKE SURE TMP FOLDER EXISTS FOR UNPACKING ARCHIVES
  mkdir -p "/tmp/retroarch"

  rm -f "$conf"
  touch "$conf"
  iniConfig " = " '"' "$conf"

  if [[ -n "$HAS_MODESET" && "${MODE_CUR[5]}" -gt 0 ]]; then
    ##SET VIDEO_REFRESH_RATE IN OUR CONFIG TO THE SAME AS THE SCREEN REFRESH
    iniSet "video_refresh_rate" "${MODE_CUR[5]}"
  fi

  ##IF THE ROM HAS A CUSTOM CONFIGURATION THEN APPEND THAT TOO
  if [[ -f "$ROM.cfg" ]]; then
    conf+="'|'\"$ROM.cfg\""
  fi

  ##IF WE ALREADY HAVE AN EXISTING APPENDCONFIG PARAMETER, WE NEED TO ADD OUR CONFIGS TO THAT
  if [[ "$COMMAND" =~ "--appendconfig" ]]; then
    COMMAND=$(echo "$COMMAND" | sed "s#\(--appendconfig *[^ $]*\)#\1'|'$conf#")
  else
    COMMAND+=" --appendconfig $conf"
  fi

  ##APPEND ANY NETPLAY CONFIGURATION
  if [[ "$NETPLAY" -eq 1 ]] && [[ -f "$RETRONETPLAY_CONF" ]]; then
    source "$RETRONETPLAY_CONF"
    COMMAND+=" -$__netplaymode $__netplayhostip_cfile --port $__netplayport --nick $__netplaynickname"
  fi
}

function get_sys_command() {
  if [[ ! -f "$EMU_SYS_CONF" ]]; then
    echo "No config found for system $SYSTEM"
    stop_joy2key
    exit 1
  fi

  ##GET SYSTEM & ROM SPECIFIC EMULATOR IF SET
  local emulator
  emulator="$(default_emulator get emu_sys)"
  if [[ -z "$emulator" ]]; then
    echo "No default emulator found for system $SYSTEM"
    start_joy2key
    choose_emulator "emu_sys" "" "--nocancel"
    stop_joy2key
    get_sys_command "$SYSTEM" "$ROM"
    return
  fi
  EMULATOR="$emulator"

  ##GET DEFAULT EMULATOR FOR SYSTEM & ROM COMBINATION
  ##TRY THE OLD KEY FIRST AND CONVERT TO THE NEW KEY IF FOUND
  emulator="$(default_emulator get emu_rom_old)"

  if [[ -n "$emulator" ]]; then
    default_emulator del emu_rom_old
    default_emulator set emu_rom "$emulator"
    EMULATOR="$emulator"
  else
    emulator="$(default_emulator get emu_rom)"
    [[ -n "$emulator" ]] && EMULATOR="$emulator"
  fi

  COMMAND="$(default_emulator get emu_cmd)"

  ##REPLACE TOKENS
  COMMAND="${COMMAND//\%ROM\%/\"$ROM\"}"
  COMMAND="${COMMAND//\%BASENAME\%/\"$ROM_BN\"}"

  ##SPECIAL CASE TO GET THE LAST 2 FOLDERS FOR QUAKE GAMES FOR THE -GAME PARAMETER
  ##REMOVE EVERYTHING UP TO /quake/
  local quake_dir="${ROM##*/quake/}"
  ##REMOVE FILENAME
  quake_dir="${quake_dir%/*}"
  COMMAND="${COMMAND//\%QUAKEDIR\%/\"$quake_dir\"}"

  ##IF IT STARTS WITH CON: IT IS A CONSOLE APPLICATION (SO WE DON'T REDIRECT STDOUT LATER)
  if [[ "$COMMAND" == CON:* ]]; then
    ##REMOVE CON:
    COMMAND="${COMMAND:4}"
    CONSOLE_OUT=1
  fi
}

function show_launch() {
  local images=()

  if [[ "$IS_SYS" -eq 1 && "$USE_ART" -eq 1 ]]; then
    ##IF USING ART LOOK FOR IMAGES IN PATHS FOR ES ART
    images+=(
      "$HOME/Arch-RGS/roms/$SYSTEM/images/${ROM_BN}-image"
      "$HOME/.emulationstation/downloaded_images/$SYSTEM/${ROM_BN}-image"
      "$HOME/.emulationstation/downloaded_media/$SYSTEM/screenshots/${ROM_BN}"
      "$HOME/Arch-RGS/roms/$SYSTEM/media/screenshots/${ROM_BN}"
    )
  fi

  ##LOOK FOR CUSTOM LAUNCHING IMAGES
  if [[ "$IS_SYS" -eq 1 ]]; then
    images+=(
      "$HOME/Arch-RGS/roms/$SYSTEM/images/${ROM_BN}-launching"
      "$CONF_ROOT/launching"
    )
  fi
  [[ "$IS_PORT" -eq 1 ]] && images+=("$CONFIGDIR/ports/launching")
  images+=("$CONFIGDIR/all/launching")

  local image
  local path
  local ext
  for path in "${images[@]}"; do
    for ext in jpg png; do
      if [[ -f "$path.$ext" ]]; then
        image="$path.$ext"
        break 2
      fi
    done
  done

  if [[ -n "$image" ]]; then
    if [[ -n "$DISPLAY" ]]; then
      feh \
        --on-last-slide quit \
        --hide-pointer \
        --fullscreen \
        --auto-zoom \
        --no-menus \
        --quiet \
        --slideshow-delay "$IMAGE_DELAY" \
        "$image"
      IMG_PID=$!
      sleep "$IMAGE_DELAY"
    fi
  elif [[ "$DISABLE_MENU" -ne 1 && "$USE_ART" -ne 1 ]]; then
    local launch_name
    if [[ -n "$ROM_BN" ]]; then
      launch_name="$ROM_BN ($EMULATOR)"
    else
      launch_name="$EMULATOR"
    fi
    DIALOGRC="$CONFIGDIR/all/runcommand-launch-dialog.cfg" dialog --infobox "\nLaunching $launch_name ...\n\nPress a button to configure\n\nErrors are logged to $LOG" 9 60
  fi
}

function check_menu() {
  local dont_launch=0
  ##CHECK FOR KEY PRESSED TO ENTER CONFIGURATION
  IFS= read -r -s -t 2 -N 1 key </dev/tty
  if [[ -n "$key" ]]; then
    [[ -n "$IMG_PID" ]] && kill -SIGINT "$IMG_PID"
    tput cnorm
    main_menu
    dont_launch=$?
    tput civis
    clear
  fi
  return $dont_launch
}

##CALLS SCRIPT WITH PARAMETERS SYSTEM, EMULATOR, ROM AND COMMANDLINE
function user_script() {
  local script="$CONFIGDIR/all/$1"
  if [[ -f "$script" ]]; then
    bash "$script" "$SYSTEM" "$EMULATOR" "$ROM" "$COMMAND" </dev/tty 2>>"$LOG"
  fi
}

function restore_cursor_and_exit() {
  ##IF WE ARE NOT BEING RUN FROM EMULATIONSTATION (GET PARENT OF PARENT), TURN THE CURSOR BACK ON
  if [[ "$(ps -o comm= -p $(ps -o ppid= -p $PPID))" != "emulationstatio" ]]; then
    tput cnorm
  fi
  exit 0
}

function launch_command() {
  local ret
  ##ESCAPE $ TO AVOID VARIABLE EXPANSION (EG ROMS CONTAINING $!)
  COMMAND="${COMMAND//\$/\\\$}"

  ##LAUNCH THE COMMAND
  echo -e "Parameters: $@\nExecuting: $COMMAND" >>"$LOG"
  if [[ "$CONSOLE_OUT" -eq 1 ]]; then
    ##TURN CURSOR ON
    tput cnorm
    eval $COMMAND </dev/tty 2>>"$LOG"
    ret=$?
    tput civis
  else
    eval $COMMAND </dev/tty &>>"$LOG"
    ret=$?
  fi
  return $ret
}

function runcommand() {
  get_config

  if ! get_params "$@"; then
    echo "$0 MODE COMMAND [SAVENAME]"
    echo "$0 MODE _SYS_/_PORT_ SYSTEM ROM"
    exit 1
  fi

  ##TURN OFF CURSOR AND CLEAR SCREEN
  tput civis
  clear

  rm -f "$LOG"
  echo -e "$SYSTEM\n$EMULATOR\n$ROM\n$COMMAND" >/dev/shm/runcommand.info
  user_script "runcommand-onstart.sh"

  set_save_vars

  load_mode_defaults

  start_joy2key
  show_launch

  if [[ "$DISABLE_MENU" -ne 1 ]]; then
    if ! check_menu; then
      stop_joy2key
      user_script "runcommand-onend.sh"
      clear
      restore_cursor_and_exit 0
    fi
  fi
  stop_joy2key

  mode_switch "$MODE_REQ_ID"

  ##REPLACE X/Y RESOLUTION AND REFRESH
  COMMAND="${COMMAND//\%XRES\%/${MODE_CUR[2]}}"
  COMMAND="${COMMAND//\%YRES\%/${MODE_CUR[3]}}"
  COMMAND="${COMMAND//\%REFRESH\%/${MODE_CUR[5]}}"

  retroarch_append_config

  ##BUILD XINITRC AND REWRITE COMMAND IF NOT ALREADY IN X11 CONTEXT
  if [[ "$XINIT" -eq 1 && "$HAS_MODESET" != "x11" ]]; then
    build_xinitrc build
  fi

  local ret
  launch_command
  ret=$?

  [[ -n "$IMG_PID" ]] && kill -SIGINT "$IMG_PID"

  clear

  ##REMOVE tmp FOLDER FOR UNPACKED ARCHIVES IF IT EXISTS
  rm -rf "/tmp/retroarch"


  ##IF WE SWITCHED MODE, RESTORE PREFERRED MODE
  mode_switch "$MODE_ORIG_ID"

  [[ "$EMULATOR" == rgs-lr-* ]] && retroarchIncludeToEnd "$CONF_ROOT/retroarch.cfg"

  user_script "runcommand-onend.sh"

  restore_cursor_and_exit "$ret"
}

runcommand "$@"


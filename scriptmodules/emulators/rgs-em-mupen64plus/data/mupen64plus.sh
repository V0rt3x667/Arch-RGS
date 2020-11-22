#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

AUDIO_PLUGIN="mupen64plus-audio-sdl"
VIDEO_PLUGIN="$1"
ROM="$2"
RSP_PLUGIN="$3"
[[ -z "$RSP_PLUGIN" ]] && RSP_PLUGIN="mupen64plus-rsp-hle"

rootdir="/opt/archrgs"
configdir="$rootdir/configs"
config="$configdir/n64/mupen64plus.cfg"
inputconfig="$configdir/n64/InputAutoCfg.ini"
datadir="$HOME/Arch-RGS"
romdir="$datadir/roms"

source "$rootdir/lib/inifuncs.sh"

function getBind() {
  ##Arg 1: Hotkey Name, Arg 2: Device Number, Arg 3: Retroarch Auto Config File
  local key
  local m64p_hotkey
  local file

  key="$1"
  m64p_hotkey="J$2"
  file="$3"

  iniConfig " = " "" "$file"

  ##Search Hotkey Enable Button
  local hotkey
  local input_type
  local i
  i=0

  for hotkey in input_enable_hotkey "$key"; do
    for input_type in "_btn" "_axis"; do
      iniGet "${hotkey}${input_type}"
      ini_value="${ini_value// /}"
    if [[ -n "$ini_value" ]]; then
      ini_value="${ini_value//\"/}"
    case "$input_type" in
      _axis)
          m64p_hotkey+="A${ini_value:1}${ini_value:0:1}"
      ;;
      _btn)
          ##If ini_value Contains "h" it is a Hat Device
          if [[ "$ini_value" == *h* ]]; then
            local dir="${ini_value:2}"
            ini_value="${ini_value:1}"
            case $dir in
            up)
              dir="1"
            ;;
            right)
              dir="2"
            ;;
            down)
              dir="4"
            ;;
            left)
              dir="8"
            ;;
            esac
            m64p_hotkey+="H${ini_value}V${dir}"
          else
            [[ "$atebitdo_hack" -eq 1 && "$ini_value" -ge 11 ]] && ((ini_value-=11))
            m64p_hotkey+="B${ini_value}"
          fi
      ;;
    esac
    fi
    done
  [[ "$i" -eq 0 ]] && m64p_hotkey+="/"
  ((i++))
  done
  echo "$m64p_hotkey"
}

function remap() {
  local device
  local devices
  local device_num

  ##Get Lists of All Present js Device Numbers and Names
  ##Get Device Count
  while read -r device; do
    device_num="${device##*/js}"
    devices[$device_num]=$(</sys/class/input/js${device_num}/device/name)
  done < <(find /dev/input -name "js*")

  ##Read retroarch Auto Config File and Use Config for mupen64plus.cfg
  local file
  local bind
  local hotkeys_rgs
  local hotkeys_m64p
  local i
  local j

  hotkeys_rgs=( "input_exit_emulator" "input_load_state" "input_save_state" )
  hotkeys_m64p=( "Joy Mapping Stop" "Joy Mapping Load State" "Joy Mapping Save State" )

  iniConfig " = " "" "$config"
  if ! grep -q "\[CoreEvents\]" "$config"; then
    echo "[CoreEvents]" >> "$config"
    echo "Version = 1" >> "$config"
  fi

  local atebitdo_hack
  for i in {0..2}; do
    bind=""
      for device_num in "${!devices[@]}"; do
        ##Get Name of retroarch Auto Config File
        file=$(grep -lF "\"${devices[$device_num]}\"" "$configdir/all/retroarch-joypads/"*.cfg)
        atebitdo_hack=0
        [[ "$file" == *8Bitdo* ]] && getAutoConf "8bitdo_hack" && atebitdo_hack=1
          if [[ -f "$file" ]]; then
            if [[ -n "$bind" && "$bind" != *, ]]; then
              bind+=","
            fi
          bind+=$(getBind "${hotkeys_rgs[$i]}" "${device_num}" "$file")
          fi
      done
    ##Write Hotkey to mupen64plus.cfg
    iniConfig " = " "\"" "$config"
    iniSet "${hotkeys_m64p[$i]}" "$bind"
  done
}

function useTexturePacks() {
  ##Video-GLideN64
  if ! grep -q "\[Video-GLideN64\]" "$config"; then
    echo "[Video-GLideN64]" >> "$config"
  fi
  iniConfig " = " "" "$config"
  ##Settings Version
  local config_version="20"
  if [[ -f "$configdir/n64/GLideN64_config_version.ini" ]]; then
    config_version=$(<"$configdir/n64/GLideN64_config_version.ini")
  fi
  iniSet "configVersion" "$config_version"
  iniSet "txHiresEnable" "True"

  ##Video-Rice
  if ! grep -q "\[Video-Rice\]" "$config"; then
    echo "[Video-Rice]" >> "$config"
  fi
  iniSet "LoadHiResTextures" "True"
}


  if ! grep -q "\[Core\]" "$config"; then
    echo "[Core]" >> "$config"
    echo "Version = 1.010000" >> "$config"
  fi
  iniConfig " = " "\"" "$config"

function setPath() {
  iniSet "ScreenshotPath" "$romdir/n64"
  iniSet "SaveStatePath" "$romdir/n64"
  iniSet "SaveSRAMPath" "$romdir/n64"
}

  ##Add Default Keyboard Configuration
  if [[ ! -f "$inputconfig" ]]; then
    cat > "$inputconfig" << _EOF_
; InputAutoCfg.ini for Mupen64Plus SDL Input plugin

; Keyboard_START
[Keyboard]
plugged = True
plugin = 2
mouse = False
DPad R = key(100)
DPad L = key(97)
DPad D = key(115)
DPad U = key(119)
Start = key(13)
Z Trig = key(122)
B Button = key(306)
A Button = key(304)
C Button R = key(108)
C Button L = key(106)
C Button D = key(107)
C Button U = key(105)
R Trig = key(99)
L Trig = key(120)
Mempak switch = key(44)
Rumblepak switch = key(46)
X Axis = key(276,275)
Y Axis = key(273,274)
; Keyboard_END

_EOF_
  fi

  getAutoConf mupen64plus_savepath && setPath
  getAutoConf mupen64plus_hotkeys && remap
  getAutoConf mupen64plus_texture_packs && useTexturePacks

  SDL_AUDIODRIVER=pulse "$rootdir/emulators/rgs-em-mupen64plus/bin/mupen64plus" \
    --noosd \
    --fullscreen \
    --rsp "${RSP_PLUGIN}.so" \
    --gfx "${VIDEO_PLUGIN}.so" \
    --audio "${AUDIO_PLUGIN}.so" \
    --configdir "$configdir/n64" \
    --datadir "$configdir/n64" \
  "$ROM"


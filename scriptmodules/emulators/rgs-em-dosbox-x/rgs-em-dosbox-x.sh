#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-dosbox-x"
archrgs_module_desc="DOSBox-X - DOS Emulator Includes Additional Patches & Features"
archrgs_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to $romdir/pc"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/joncampbell123/dosbox-x/master/COPYING"
archrgs_module_section="emulators"

function install_bin_rgs-em-dosbox-x() {
  pacmanPkg rgs-em-dosbox-x
}

function remove_rgs-em-dosbox-x() {
  pacmanRemove rgs-em-dosbox-x
}

function configure_rgs-em-dosbox-x() {
  local def
  local launcher_name
  local config_path

  def="0"
  launcher_name="+Start DOSBox-X.sh"
  config_path=$(su "$user" -c "\"$md_inst/bin/dosbox-x\" -printconf")

  mkRomDir "pc"

  rm -f "$romdir/pc/$launcher_name"
  if [[ "$md_mode" == "install" ]]; then
    cat > "$romdir/pc/$launcher_name" << _EOF_
#!/bin/bash

  params=("\$@")
  if [[ -z "\${params[0]}" ]]; then
    params=(-c "@MOUNT C $romdir/pc -freesize 1024" -c "@C:")
  elif [[ "\${params[0]}" == *.sh ]]; then
    bash "\${params[@]}"
    exit
  elif [[ "\${params[0]}" == *.conf ]]; then
    params=(-userconf -conf "\${params[@]}")
  else
    params+=(-exit)
  fi

  "$md_inst/bin/dosbox-x" "\${params[@]}"
_EOF_
  chmod +x "$romdir/pc/$launcher_name"
  chown "$user:$user" "$romdir/pc/$launcher_name"

    if [[ -f "$config_path" ]]; then
      iniConfig " = " "" "$config_path"
      iniSet "usescancodes" "false"
      iniSet "core" "dynamic"
      iniSet "cycles" "max"
      iniSet "scaler" "none"
        if [[ -n "$(aconnect -o | grep -e "FLUID Synth")" ]]; then
          iniSet "mididevice" "fluidsynth"
          iniSet "fluid.driver" "pulseaudio"
          iniSet "fluid.soundfont" "/usr/share/soundfonts/FluidR3_GM.sf2"
        fi
      iniSet "fullscreen" "true"
      iniSet "fullresolution" "desktop"
      iniSet "output" "overlay"
    fi
  fi

  moveConfigDir "$home/.config/dosbox-x" "$md_conf_root/pc"

  addEmulator "$def" "$md_id" "pc" "bash $romdir/pc/${launcher_name// /\\ } %ROM%"
  addSystem "pc"
}


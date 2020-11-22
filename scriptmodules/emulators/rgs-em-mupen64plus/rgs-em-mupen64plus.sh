#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-mupen64plus"
archrgs_module_desc="MUPEN64Plus - Nintendo N64 Emulator"
archrgs_module_help="ROM Extensions: .z64 .n64 .v64 .zip\n\nCopy your N64 roms to $romdir/n64"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/mupen64plus/mupen64plus-core/master/LICENSES"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-mupen64plus() {
  pacmanPkg rgs-em-mupen64plus
}

function remove_rgs-em-mupen64plus() {
  pacmanRemove rgs-em-mupen64plus
}

function configure_rgs-em-mupen64plus() {
  addEmulator 1 "${md_id}-GLideN64-HLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
  addEmulator 0 "${md_id}-Glide64mk2-HLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM%"
  addEmulator 0 "${md_id}-Rice-HLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM%"
  addEmulator 0 "${md_id}-GLideN64-LLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% mupen64plus-rsp-cxd4-sse2"
  addEmulator 0 "${md_id}-AngryLion-LLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-angrylion-plus %ROM% mupen64plus-rsp-cxd4-sse2"
  addEmulator 0 "${md_id}-Z64-LLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-z64 %ROM% mupen64plus-rsp-z64"
  addEmulator 0 "${md_id}-Arachnoid-HLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-arachnoid %ROM%"
  addSystem "n64"

  mkRomDir "n64"

  [[ "$md_mode" == "remove" ]] && return

  ##COPY HOTKEY REMAPPING START SCRIPT
  cp "$md_data/mupen64plus.sh" "$md_inst/bin"
  chmod +x "$md_inst/bin/mupen64plus.sh"

  mkUserDir "$md_conf_root/n64"

  moveConfigDir "$home/.config/mupen64plus" "$md_conf_root/n64"

  ##COPY CONFIG FILES
  cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf} "$md_conf_root/n64"

  ##REMOVE DEFAULT InputAutoConfig.ini
  rm -f "$md_conf_root/n64/InputAutoCfg.ini"

  local config
  local cmd

  config="$md_conf_root/n64/mupen64plus.cfg"
  cmd="$md_inst/bin/mupen64plus --configdir $md_conf_root/n64 --datadir $md_conf_root/n64"

  ##1) BACK UP EXISTING mupen64plus CONFIG & GENERATE NEW CONFIGURATION FILE
  ##2) COPY NEW CONFIG FILE TO rgs-dist AND RESTORE THE ORIGINAL CONFIG FILE
  ##3) MAKE INI CHANGES ON rgs-dist File. PRESERVES USER CONFIGS FROM MODIFICATION AND CREATES A DEFAULT CONFIG FOR REFERENCE
  if [[ -f "$config" ]]; then
    mv "$config" "$config.user"
    su "$user" -c "$cmd"
    mv "$config" "$config.rgs-dist"
    mv "$config.user" "$config"
    config+=".rgs-dist"
  else
    su "$user" -c "$cmd"
  fi

  addAutoConf mupen64plus_hotkeys 1
  addAutoConf mupen64plus_texture_packs 1

  chown -R "$user:$user" "$md_conf_root/n64"
}


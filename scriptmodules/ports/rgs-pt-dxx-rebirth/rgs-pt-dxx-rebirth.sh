#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-dxx-rebirth"
archrgs_module_desc="DXX-Rebirth - Descent & Descent 2 Source Port"
archrgs_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
archrgs_module_section="ports"
archrgs_module_flags="x86_64"

function install_bin_rgs-pt-dxx-rebirth() {
  pacmanPkg rgs-pt-dxx-rebirth
}

function remove_rgs-pt-dxx-rebirth() {
  pacmanRemove rgs-pt-dxx-rebirth
}

function game_data_rgs-pt-dxx-rebirth() {
  local D1X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
  local D2X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
  local D1X_HIGH_TEXTURE_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
  local D1X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
  local D2X_OGG_URL='https://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'

  local dest_d1="$romdir/ports/descent1"
  local dest_d2="$romdir/ports/descent2"

  mkUserDir "$dest_d1"
  mkUserDir "$dest_d2"

  ##Download, Unpack & Install Descent Shareware Files
  if [[ ! -f "$dest_d1/descent.hog" ]]; then
    downloadAndExtract "$D1X_SHARE_URL" "$dest_d1"
  fi

  ##High Res Texture Pack
  if [[ ! -f "$dest_d1/d1xr-hires.dxa" ]]; then
    download "$D1X_HIGH_TEXTURE_URL" "$dest_d1"
  fi

  ##Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
  if [[ ! -f "$dest_d1/d1xr-sc55-music.dxa" ]]; then
    download "$D1X_OGG_URL" "$dest_d1"
  fi

  ##Download, Unpack & Install Descent 2 Shareware Files
  if [[ ! -f "$dest_d2/D2DEMO.HOG" ]]; then
    downloadAndExtract "$D2X_SHARE_URL" "$dest_d2"
  fi

  ##Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
  if [[ ! -f "$dest_d2/d2xr-sc55-music.dxa" ]]; then
    download "$D2X_OGG_URL" "$dest_d2"
  fi

  chown -R "$user:$user" "$dest_d1" "$dest_d2"
}

function configure_rgs-pt-dxx-rebirth() {
  local config
  local ver
  local name

  name="Descent Rebirth"

  for ver in 1 2; do
    [[ "$ver" -eq 2 ]] && name="Descent 2 Rebirth"
    addPort "$md_id" "descent${ver}" "$name" "$md_inst/bin/d${ver}x-rebirth -hogdir $romdir/ports/descent${ver}"

    [[ "$md_mode" == "remove" ]] && continue

    mkRomDir "ports/descent${ver}"

    moveConfigDir "$home/.d${ver}x-rebirth" "$md_conf_root/descent${ver}/"
  done

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-dxx-rebirth
}


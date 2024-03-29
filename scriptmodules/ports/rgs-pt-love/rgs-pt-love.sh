#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-love"
archrgs_module_desc="Love - 2D Game Framework for Lua"
archrgs_module_help="Copy Your Love Games (.love) to $romdir/love"
archrgs_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/master/license.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-love() {
  pacmanPkg rgs-pt-love
}

function remove_rgs-pt-love() {
  pacmanRemove rgs-pt-love
}

function game_data_rgs-pt-love() {
  ##Get Mari0 (Freeware Game Data)
  if [[ ! -f "$romdir/love/mari0.love" ]]; then
    downloadAndExtract "https://github.com/Stabyourself/mari0/archive/1.6.2.tar.gz" "$__tmpdir/mari0" --strip-components 1
    pushd "$__tmpdir/mari0"
    zip -qr "$romdir/love/mari0.love" .
    popd
    rm -fr "$__tmpdir/mari0"
    chown "$user:$user" "$romdir/love/mari0.love"
  fi
}

function configure_rgs-pt-love() {
  setConfigRoot ""

  mkRomDir "love"

  if [[ "$md_id" == rgs-pt-love-legacy ]]; then
    addEmulator 0 "$md_id" "love" "$md_inst/bin/love %ROM%"
  else
    addEmulator 1 "$md_id" "love" "$md_inst/bin/love %ROM%"
  fi
  addSystem "love"

  [[ "$md_mode" == "install" ]] && game_data_rgs-pt-love
}


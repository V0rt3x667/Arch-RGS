#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-love-legacy"
archrgs_module_desc="2D Game Framework for Lua v0.10.2"
archrgs_module_help="Copy Your Love Games to $romdir/love"
archrgs_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/0.10.2/license.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-love-legacy() {
  pacmanPkg rgs-pt-love-legacy
}

function remove_rgs-pt-love-legacy() {
  pacmanRemove rgs-pt-love-legacy
}

function game_data_rgs-pt-love-legacy() {
  game_data_rgs-pt-love
}

function configure_rgs-pt-love-legacy() {
  configure_rgs-pt-love
}


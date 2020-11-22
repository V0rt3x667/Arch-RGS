#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-lr-vecx"
archrgs_module_desc="GCE Vectrex Libretro Core"
archrgs_module_help="ROM Extensions: .vec .gam .bin .zip\n\nCopy your Vectrex roms to $romdir/vectrex"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/libretro/libretro-vecx/master/LICENSE.md"
archrgs_module_section="libretrocores"

function install_bin_rgs-lr-vecx() {
  pacmanPkg rgs-lr-vecx
}

function remove_rgs-lr-vecx() {
  pacmanRemove rgs-lr-vecx
}

function configure_rgs-lr-vecx() {
  mkRomDir "vectrex"

  ensureSystemretroconfig "vectrex"

  if [[ "$md_mode" == "install" ]]; then
    ##Copy BIOS Files
    cp -v "$md_inst/"{fast.bin,skip.bin,system.bin} "$biosdir/"
    chown "$user:$user" "$biosdir/"{fast.bin,skip.bin,system.bin}
  else
    rm -f "$biosdir/"{fast.bin,skip.bin,system.bin}
  fi

  addEmulator 1 "$md_id" "vectrex" "$md_inst/vecx_libretro.so"
  addSystem "vectrex"
}


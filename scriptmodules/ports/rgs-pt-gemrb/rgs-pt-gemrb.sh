#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-gemrb"
archrgs_module_desc="Port of Bioware's Infinity Engine"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/gemrb/gemrb/master/COPYING"
archrgs_module_section="ports"

function install_bin_rgs-pt-gemrb() {
  pacmanPkg rgs-pt-gemrb
}

function remove_rgs-pt-gemrb() {
  pacmanRemove rgs-pt-gemrb
}

function configure_rgs-pt-gemrb() {
  mkRomDir ports/{baldurs1,baldurs2,icewind1,icewind2,planescape,cache}

  addPort "$md_id" "baldursgate1" "Baldurs Gate 1" "$md_inst/gemrb -C $md_conf_root/baldursgate1/GemRB.cfg"
  addPort "$md_id" "baldursgate2" "Baldurs Gate 2" "$md_inst/gemrb -C $md_conf_root/baldursgate2/GemRB.cfg"
  addPort "$md_id" "icewind1" "Icewind Dale 1" "$md_inst/gemrb -C $md_conf_root/icewind1/GemRB.cfg"
  addPort "$md_id" "icewind2" "Icewind Dale 2" "$md_inst/gemrb -C $md_conf_root/icewind2/GemRB.cfg"
  addPort "$md_id" "planescape" "Planescape Torment" "$md_inst/gemrb -C $md_conf_root/planescape/GemRB.cfg"

  ##Create Baldurs Gate 1 Configuration
  cat > "$md_conf_root/baldursgate1/GemRB.cfg" << _EOF_
GameType=bg1
GameName=Baldurs Gate 1
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=$romdir/ports/baldurs1/
CD1=$romdir/ports/baldurs1/
CachePath=$romdir/ports/baldurs1/cache/
_EOF_

  ##Create Baldurs Gate 2 Configuration
  cat > "$md_conf_root/baldursgate2/GemRB.cfg" << _EOF_
GameType=bg2
GameName=Baldurs Gate 2
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=$romdir/ports/baldurs2
CD1=$romdir/ports/baldurs2/data
CD2=$romdir/ports/baldurs2/data
CD3=$romdir/ports/baldurs2/data
CD4=$romdir/ports/baldurs2/data
CD5=$romdir/ports/baldurs2/data
CD6=$romdir/ports/baldurs2/data
CachePath=$romdir/ports/baldurs2/cache
_EOF_

  ##Create Icewind Dale 1 Configuration
  cat > "$md_conf_root/icewind1/GemRB.cfg" << _EOF_
GameType=auto
GameName=Icewind Dale 1
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=$romdir/ports/icewind1/
CD1=$romdir/ports/icewind1/Data/
CD2=$romdir/ports/icewind1/CD2/Data/
CD3=$romdir/ports/icewind1/CD3/Data/
CachePath=$romdir/ports/icewind1/cache/
_EOF_

  ##Create Icewind2 Dale Configuration
  cat > "$md_conf_root/icewind2/GemRB.cfg" << _EOF_
GameType=iwd2
GameName=Icewind Dale 2
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=$romdir/ports/icewind2/
CD1=$romdir/ports/icewind2/data/
CachePath=$romdir/ports/icewind2/cache/
_EOF_

  ##Create Planescape Configuration
  cat > "$md_conf_root/planescape/GemRB.cfg" << _EOF_
GameType=pst
GameName=Planescape Torment
Width=800
Height=600
Bpp=32
Fullscreen=1
TooltipDelay=500
AudioDriver = openal
GUIEnhancements = 15
DrawFPS=0
CaseSensitive=1
GamePath=$romdir/ports/planescape/
CD1=$romdir/ports/planescape/data/
CachePath=$romdir/ports/planescape/cache/
_EOF_

  for game in 'baldursgate1' 'baldursgate2' 'icewind1' 'icewind2' 'planescape'; do
    chown "$user:$user" "$md_conf_root/${game}/GemRB.cfg"
  done
}


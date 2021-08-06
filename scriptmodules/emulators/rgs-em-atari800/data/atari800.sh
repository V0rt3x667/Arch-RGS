#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

ROM="$1"
MODEL=$2

rootdir="/opt/archrgs"
datadir="$HOME/Arch-RGS"
romdir="$datadir/roms"
savedir="$romdir"
biosdir="$datadir/bios"

source "$rootdir/lib/archivefuncs.sh"

function check_arch_files() {

  case "$MODEL" in
    Atari800-PAL|Atari800-NTSC|Atari800XL|Atari130XE|Atari5200)
    archiveExtract "$ROM" ".a52 .atr .bas .bin .car .dcm .xex .xfd"
      ##Check Successful Extraction And If We Have At Least One File
      if [[ $? == 0 ]]; then
        ROM="${arch_files[0]}"
        romdir="$arch_dir"
      fi
    launch_atari
    ;;
  esac
}

function launch_atari() {

  case "$MODEL" in
    Atari800-PAL)
      "$rootdir/emulators/rgs-em-atari800/bin/atari800" \
      -atari \
      -pal \
      -fullscreen \
      -osa_rom "$biosdir/ATARIOSA.ROM" \
      "$ROM" \
      -800-rev a-pal \
      -atari_files "$romdir" \
      -saved_files "$savedir/atari800"
      ;;
    Atari800-NTSC)
      "$rootdir/emulators/rgs-em-atari800/bin/atari800" \
      -atari \
      -ntsc \
      -fullscreen \
      -osb_rom "$biosdir/ATARIOSB.ROM" \
      "$ROM" \
      -800-rev b-ntsc \
      -atari_files "$romdir" \
      -saved_files "$savedir/atari800"
      ;;
    Atari800XL)
      "$rootdir/emulators/rgs-em-atari800/bin/atari800" \
      -xl \
      -ntsc \
      -fullscreen \
      -xlxe_rom "$biosdir/ATARIXL.ROM" \
      "$ROM" \
      -atari_files "$romdir" \
      -saved_files "$savedir/atari800"
      ;;
    Atari130XE)
      "$rootdir/emulators/rgs-em-atari800/bin/atari800" \
      -xe \
      -ntsc \
      -fullscreen \
      -xlxe_rom "$biosdir/ATARIXL.ROM" \
      "$ROM" \
      -atari_files "$romdir" \
      -saved_files "$savedir/atari800"
      ;;
    Atari5200)
      "$rootdir/emulators/rgs-em-atari800/bin/atari800" \
      -5200 \
      -ntsc \
      -fullscreen \
      -5200_rom "$biosdir/5200.rom" \
      -cart "$ROM" \
      -5200-rev orig \
      -atari_files "$romdir" \
      -saved_files "$savedir/atari5200"
      ;;
  esac
}

check_arch_files
archiveCleanup

#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-csp-fm7"
archrgs_module_desc="CSP-FM7 - Fujitsu FM-8, FM-7, 77AV, 77AV40, 77AV40EX & 77AV40SX Emulator"
archrgs_module_help="ROM Extensions: .d77 .t77 .d88 .2d \n\nCopy Your FM-7 Games to: $romdir/fm7\n\nCopy Your BIOS File(s) to: $biosdir/fm7\n\n  DICROM.ROM\n  EXTSUB.ROM\n  FBASIC30.ROM\n  INITIATE.ROM\n  KANJI1.ROM\n  KANJI2.ROM\n  SUBSYS_A.ROM\n  SUBSYS_B.ROM\n  SUBSYSCG.ROM\n  SUBSYS_C.ROM\n  fddseek.wav\n  relayoff.wav\n  relay_on.wav"
archrgs_module_licence="GPL2 https://raw.githubusercontent.com/Artanejp/common_source_project-fm7/master/README.en.md"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-csp-fm7() {
  pacmanPkg rgs-em-csp-fm7
}

function remove_rgs-em-csp-fm7() {
  pacmanRemove rgs-em-csp-fm7
}

function configure_rgs-em-csp-fm7() {
  mkRomDir "fm7"
  mkUserDir "$biosdir/fm7"

  addEmulator 1 "csp-fm8" "fm7" "$md_inst/bin/emufm8 %ROM%"
  addEmulator 1 "csp-fm7" "fm7" "$md_inst/bin/emufm7 %ROM%"
  addEmulator 1 "csp-fm77av" "fm7" "$md_inst/bin/emufm77av %ROM%"
  addEmulator 1 "csp-fm77av40" "fm7" "$md_inst/bin/emufm77av40 %ROM%"
  addEmulator 1 "csp-fm77av40ex" "fm7" "$md_inst/bin/emufm77av40ex %ROM%"
  addEmulator 1 "csp-fm77av40sx" "fm7" "$md_inst/bin/emufm77av40sx %ROM%"
  addSystem "fm7"

  [[ "$md_mode" == "remove" ]] && return

  moveConfigDir "$home/.config/CommonSourceCodeProject" "$md_conf_root/fm7"
  moveConfigDir "$home/CommonSourceCodeProject" "$md_conf_root/fm7"

  local dirs
  dirs=(
    'emufm8'
    'emufm7'
    'emufm77av'
    'emufm77av40'
    'emufm77av40ex'
    'emufm77av40sx'
)
  for dir in ${dirs[@]}; do
    mkUserDir "$md_conf_root/fm7/$dir"
    ln -snf "$md_conf_root/fm7/$dir" "$biosdir/fm7/$dir"
  done
}


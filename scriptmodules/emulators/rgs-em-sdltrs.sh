#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-sdltrs"
archrgs_module_desc="Radio Shack TRS-80 Model I/III/4/4P emulator"
archrgs_module_help="ROM Extension: .dsk\n\nCopy your TRS-80 games to $romdir/trs-80\n\nCopy the required BIOS file level2.rom, level3.rom, level4.rom or level4p.rom to $biosdir"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-sdltrs() {
    pacmanPkg rgs-em-sdltrs
}

function remove_rgs-em-sdltrs() {
    pacmanRemove rgs-em-sdltrs
}

function configure_rgs-em-sdltrs() {
    mkRomDir "trs-80"

    addEmulator 1 "$md_id-model1" "trs-80" "$md_inst/sdltrs -model 1 -romfile $biosdir/level2.rom -showled -diskdir $romdir/trs-80 -disk0 %ROM%"
    addEmulator 0 "$md_id-model3" "trs-80" "$md_inst/sdltrs -model 3 -romfile3 $biosdir/level3.rom -showled -diskdir $romdir/trs-80 -disk0 %ROM%"
    addEmulator 0 "$md_id-model4" "trs-80" "$md_inst/sdltrs -model 4 -romfile3 $biosdir/level4.rom -showled -diskdir $romdir/trs-80 -disk0 %ROM%"
    addEmulator 0 "$md_id-model4p" "trs-80" "$md_inst/sdltrs -model 4p -romfile4p $biosdir/level4p.rom -showled -diskdir $romdir/trs-80 -disk0 %ROM%"
    addSystem "trs-80"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigFile "$home/sdltrs.t8c" "$md_conf_root/trs-80/sdltrs.t8c"

    local rom
    for rom in level2.rom level3.rom level4.rom level4p.rom; do
        ln -sf "$biosdir/$rom" "$md_inst/$rom"
    done

}

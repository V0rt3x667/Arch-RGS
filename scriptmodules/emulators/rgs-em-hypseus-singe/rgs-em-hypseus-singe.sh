#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-em-hypseus-singe"
archrgs_module_desc="Hypseus-Singe - Super Multiple Arcade Laserdisc Emulator"
archrgs_module_help="ROM Extension: .daphne\n\nCopy Your Laserdisc ROMs to $romdir/daphne"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/hypseus-singe/master/LICENSE"
archrgs_module_section="emulators"
archrgs_module_flags="x86_64"

function install_bin_rgs-em-hypseus-singe() {
  pacmanPkg rgs-em-hypseus-singe
}

function remove_rgs-em-hypseus-singe() {
  pacmanRemove rgs-em-hypseus-singe
}

function configure_rgs-em-hypseus-singe() {
  local dirs
  dirs=(
    'pics'
    'ram'
    'roms'
    'sound'
    'singe'
    'vldp'
    'vldp_dl'
)

  for dir in "${dirs[@]}"; do
    mkRomDir "daphne/$dir"
  done
  mkUserDir "$md_conf_root/daphne"

  moveConfigDir "$home/.hypseus" "$md_conf_root/daphne"

  if [[ "$md_mode" == "install" ]] && [[ ! -f "$md_conf_root/daphne/hypinput.ini && ! -f $md_conf_root/daphne/flightkey.ini" ]]; then
    cp -v "$md_inst/doc/"*.ini "$md_conf_root/daphne"
    cp -r "$md_inst/fonts" "$md_conf_root/daphne"
    chown -R "$user:$user" "$md_conf_root/daphne"
  fi

  addEmulator 1 "$md_id" "daphne" "$md_inst/daphne %ROM%"
  addSystem "daphne"

  [[ "$md_mode" == "remove" ]] && return

  cat >"$md_inst/daphne.sh" <<_EOF_
  #!/usr/bin/bash

  HYPSEUS_SHARE="$romdir/daphne"
  HYPSEUS_BIN="md_inst/hypseus"

  case "$1" in
    ace)
      VLDP_DIR="vldp_dl"
      FASTBOOT="-fastboot"
      BANKS="-bank 1 00000001 -bank 0 00000010"
    ;;
    astron)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    badlands)
      VLDP_DIR="vldp"
      BANKS="-bank 1 10000001 -bank 0 00000000"
    ;;
    bega)
      VLDP_DIR="vldp"
    ;;
    blazer)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    cliff)
      VLDP_DIR="vldp"
      FASTBOOT="-fastboot"
      BANKS="-bank 1 00000000 -bank 0 00000000 -cheat"
    ;;
    cobra)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    cobraab)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    dle21)
      VLDP_DIR="vldp_dl"
      BANKS="-bank 1 00110111 -bank 0 11011000"
    ;;
    esh)
      ##Run a Fixed ROM So Disable CRC
      VLDP_DIR="vldp"
      FASTBOOT="-nocrc"
    ;;
    galaxy)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    gpworld)
      VLDP_DIR="vldp"
    ;;
    interstellar)
      VLDP_DIR="vldp"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    mach3)
     VLDP_DIR="vldp"
     BANKS="-bank 0 01000001"
     KEYINPUT="-keymapfile flightkey.ini"
    ;;
    lair)
      VLDP_DIR="vldp_dl"
      FASTBOOT="-fastboot"
      BANKS="-bank 1 00110111 -bank 0 10011000"
    ;;
    lair2)
      VLDP_DIR="vldp_dl"
    ;;
    roadblaster)
      VLDP_DIR="vldp"
    ;;
    sae)
      VLDP_DIR="vldp_dl"
      BANKS="-bank 1 01100111 -bank 0 10011000"
    ;;
    sdq)
      VLDP_DIR="vldp"
      BANKS="-bank 1 00000000 -bank 0 00000000"
    ;;
    tq)
      VLDP_DIR="vldp_dl"
      BANKS=" -bank 0 00010000"
    ;;
    uvt)
      VLDP_DIR="vldp"
      BANKS="-bank 0 01000000"
      KEYINPUT="-keymapfile flightkey.ini"
    ;;
    *)
      echo -e "\nInvalid game selected\n"
      exit 1
  esac

  if [ ! -f $HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt ]; then
    echo
    echo "Missing Frame File: $HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt ?" | STDERR
    echo
    exit 1
  fi

  "$HYPSEUS_BIN" $1 vldp \
  "$FASTBOOT" \
  "$KEYINPUT" \
  "$BANKS" \
  -framefile "$HYPSEUS_SHARE/$VLDP_DIR/$1/$1.txt" \
  -homedir "$home/.hypseus" \
  -datadir "$HYPSEUS_SHARE" \
  -fullscreen
  -sound_buffer 2048 \
  -volume_nonvldp 5 \
  -volume_vldp 20
_EOF_
  chmod +x "$md_inst/daphne.sh"
}


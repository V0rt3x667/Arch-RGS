#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-splitwolf"
archrgs_module_desc="SplitWolf - 2-4 Player Split-Screen Wolfenstein 3D & Spear of Destiny Port"
archrgs_module_help="Game File Extension: .wl1, .wl6, .sdm, .sod, .sd2, .sd3\n\nCopy Your Wolfenstein 3D & Spear of Destiny Game Files to $romdir/ports/wolf3d/"
archrgs_module_licence="NONCOM https://bitbucket.org/linuxwolf6/splitwolf/raw/scrubbed/license-mame.txt"
archrgs_module_section="ports"

function install_bin_rgs-pt-splitwolf() {
  pacmanPkg rgs-pt-splitwolf
}

function remove_rgs-pt-splitwolf() {
  pacmanRemove rgs-pt-splitwolf
}

function _add_games_rgs-pt-splitwolf() {
  declare -A -g games=(
    ['vswap.sod']="SplitWolf - Spear of Destiny"
    ['vswap.sd1']="SplitWolf - Spear of Destiny"
    ['vswap.sd2']="SplitWolf - Spear of Destiny Mission Pack 2 - Return to Danger"
    ['vswap.sd3']="SplitWolf - Spear of Destiny Mission Pack 3 - Ultimate Challenge"
    ['vswap.sdm']="SplitWolf - Spear of Destiny (Shareware)"
    ['vswap.wl1']="SplitWolf - Wolfenstein 3D (Shareware)"
    ['vswap.wl6']="SplitWolf - Wolfenstein 3D"
)
  _add_ports_rgs-pt-splitwolf "$md_inst/bin/splitwolf.sh %ROM%" "splitwolf"
}

function _add_ports_rgs-pt-splitwolf() {
  local cmd="$1"
  local game
  local wad

  for game in "${!games[@]}"; do
    wad="$romdir/ports/wolf3d/$game"
    if [[ -f "$wad" ]]; then
      addPort "$md_id" "splitwolf" "${games[$game]}" "$cmd" "$wad"
    fi
  done
}

function configure_rgs-pt-splitwolf() {
  mkRomDir "ports/wolf3d"

  if [[ "$md_mode" == "install" ]]; then
    game_data_rgs-pt-ecwolf
    chown -R "$user:$user" "$romdir/ports/wolf3d"
    cat > "$md_inst/bin/splitwolf.sh" << _EOF_
#!/usr/bin/env bash

function get_md5sum() {
  local file="\$1"

  [[ -n "\$file" ]] && md5sum "\$file" 2>/dev/null | cut -d" " -f1
}

function launch_rgs-pt-splitwolf() {
  local wad_file="\$1"
  declare -A game_checksums=(
    ['6efa079414b817c97db779cecfb081c9']="splitwolf-wolf3d_shareware"
    ['a6d901dfb455dfac96db5e4705837cdb']="splitwolf-wolf3d_apogee"
    ['b8ff4997461bafa5ef2a94c11f9de001']="splitwolf-wolf3d_full"
    ['b1dac0a8786c7cdbb09331a4eba00652']="splitwolf-spear_full"
    ['b1dac0a8786c7cdbb09331a4eba00652']="splitwolf-spear_full --mission 1"
    ['25d92ac0ba012a1e9335c747eb4ab177']="splitwolf-spear_mission-packs --mission 2"
    ['94aeef7980ef640c448087f92be16d83']="splitwolf-spear_mission-packs --mission 3"
    ['35afda760bea840b547d686a930322dc']="splitwolf-spear_shareware"
)
  if [[ "\${game_checksums[\$(get_md5sum \$wad_file)]}" ]] 2>/dev/null; then
    $md_inst/bin/\${game_checksums[\$(get_md5sum \$wad_file)]} --splitdatadir $md_inst/bin/lwmp/ --split 2 --splitlayout 2x1
  else
    echo "Error: \$wad_file (md5: \$(get_md5sum \$wad_file)) is not a supported version"
  fi
}

launch_rgs-pt-splitwolf "\$1"

_EOF_
    chmod +x "$md_inst/bin/splitwolf.sh"
  fi

  _add_games_rgs-pt-splitwolf

  moveConfigDir "$home/.splitwolf" "$md_conf_root/splitwolf"
}

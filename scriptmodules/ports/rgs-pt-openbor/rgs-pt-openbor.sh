#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-pt-openbor"
archrgs_module_desc="OpenBOR - Beat 'Em Up Game Engine"
archrgs_module_help="OpenBOR games need to be extracted to function properly. Place your pak files in $romdir/ports/openbor and then run $rootdir/ports/openbor/extract.sh. When the script is done, your original pak files will be found in $romdir/ports/openbor/originals and can be deleted."
archrgs_module_licence="BSD https://raw.githubusercontent.com/rofl0r/openbor/master/LICENSE"
archrgs_module_section="ports"

function install_bin_rgs-pt-openbor() {
  pacmanPkg rgs-pt-openbor
}

function remove_rgs-pt-openbor() {
  pacmanRemove rgs-pt-openbor
}

function configure_rgs-pt-openbor() {
  addPort "$md_id" "openbor" "OpenBOR - Beats of Rage Engine" "$md_inst/bin/openbor.sh"

  mkRomDir "ports/openbor"

  cat >"$md_inst/bin/openbor.sh" << _EOF_
#!/usr/bin/env bash
pushd "$md_inst/bin"
./OpenBOR "\$@"
popd
_EOF_
  chmod +x "$md_inst/bin/openbor.sh"

  cat >"$md_inst/bin/extract.sh" <<_EOF_
#!/usr/bin/env bash
PORTDIR="$md_inst/bin"
BORROMDIR="$romdir/ports/openbor"
mkdir \$BORROMDIR/original/
mkdir \$BORROMDIR/original/borpak/
mv \$BORROMDIR/*.pak \$BORROMDIR/original/
cp \$PORTDIR/paxplode \$BORROMDIR/original/
cp \$PORTDIR/borpak \$BORROMDIR/original/borpak/
cd \$BORROMDIR/original/
for i in *.pak
do
  CURRENTFILE=\`basename "\$i" .pak\`
  ./paxplode "\$i"
  mkdir "\$CURRENTFILE"
  mv data/ "\$CURRENTFILE"/
  mv "\$CURRENTFILE"/ ../
done
echo "Your games are extracted and ready to be played. Your originals are stored safely in $BORROMDIR/original/ but they won't be needed anymore. Everything within it can be deleted."
_EOF_
  chmod +x "$md_inst/bin/extract.sh"

  local dir
  for dir in ScreenShots Logs Saves; do
    mkUserDir "$md_conf_root/openbor/$dir"
    ln -snf "$md_conf_root/openbor/$dir" "$md_inst/$dir"
  done

  ln -snf "$romdir/ports/openbor" "$md_inst/Paks"
}


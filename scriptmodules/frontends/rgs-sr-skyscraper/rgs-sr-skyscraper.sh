#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="rgs-sr-skyscraper"
archrgs_module_desc="Skyscraper - Powerful & Versatile Game Scraper"
archrgs_module_licence="GPL3 https://raw.githubusercontent.com/muldjord/skyscraper/master/LICENSE"
archrgs_module_section="exp"

function install_bin_rgs-sr-skyscraper() {
  pacmanPkg rgs-sr-skyscraper
}

function remove_rgs-sr-skyscraper() {
  pacmanRemove rgs-sr-skyscraper

  _purge_rgs-sr-skyscraper
}

##GET THE LOCATION OF THE CACHED RESOURCES FOLDER. IN V3+ THIS CHANGED TO 'cache'
##NOTE: THE CACHE FOLDER MIGHT BE UNAVAILABLE DURING FIRST TIME INSTALLATIONS
function _cache_folder_rgs-sr-skyscraper() {
  if [[ -d "$configdir/all/skyscraper/dbs" ]]; then
    echo "dbs"
  else
    echo "cache"
  fi
}

##PURGE ALL SKYSCRAPER CACHES
function _purge_rgs-sr-skyscraper() {
  local platform
  local cache_folder
  cache_folder=$(_cache_folder_rgs-sr-skyscraper)

  [[ ! -d "$configdir/all/skyscraper/$cache_folder" ]] && return

  while read platform; do
    ##FIND ANY SUB-FOLDERS OF THE CACHE FOLDER AND CLEAR THEM
    _clear_platform_rgs-sr-skyscraper "$platform"
  done < <(find "$configdir/all/skyscraper/$cache_folder" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
}

function _clear_platform_rgs-sr-skyscraper() {
  local platform="$1"
  local mode="$2"
  local cache_folder
  cache_folder=$(_cache_folder_rgs-sr-skyscraper)

  [[ ! -d "$configdir/all/skyscraper/$cache_folder/$platform" ]] && return

  if [[ $mode == "vacuum" ]]; then
    sudo -u "$user" stdbuf -o0 "$md_inst"/bin/Skyscraper --unattend -p "$platform" --cache vacuum
  else
    sudo -u "$user" stdbuf -o0 "$md_inst"/bin/Skyscraper --unattend -p "$platform" --cache purge:all
  fi
  sleep 5
}

function _purge_platform_rgs-sr-skyscraper() {
  local options=()
  local cache_folder
  local system
  cache_folder=$(_cache_folder_rgs-sr-skyscraper)

  while read system; do
    ##IF THERE IS NO 'db.xml' FILE UNDERNEATH THE FOLDER SKIP IT THEFOLDER IS EMPTY
    [[ ! -f "$configdir/all/skyscraper/$cache_folder/$system/db.xml" ]] && continue

    ##GET THE SIZE ON DISK OF THE SYSTEM AND SHOW IT IN THE SELECT LIST
    local size
    size=$(du -sh "$configdir/all/skyscraper/$cache_folder/$system" | cut -f1)
    options+=("$system" "$size" OFF)
  done < <(find "$configdir/all/skyscraper/$cache_folder" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

  ##IF NOT FOLDERS ARE FOUND SHOW AN INFO MESSAGE INSTEAD OF THE SELECTION LIST
  if [[ ${#options[@]} -eq 0 ]]; then
    printMsgs "dialog" "Nothing to delete ! No cached platforms found in \n$configdir/all/skyscraper/$cache_folder."
    return
  fi

  local mode="$1"
  [[ -z "$mode" ]] && mode="purge"

  local cmd=(dialog --backtitle "$__backtitle" --radiolist "Select platform to $mode" 20 60 12)
  local platform
  platform=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

  ##EXIT IF NO PLATFORM CHOSEN
  [[ -z "$platform" ]] && return

  _clear_platform_rgs-sr-skyscraper "$platform" "$@"
}

function _get_ver_rgs-sr-skyscraper() {
  if [[ -f "$md_inst/bin/Skyscraper" ]]; then
    printf '%s\n' "$("$md_inst/bin/Skyscraper" -h | grep 'Running Skyscraper' | cut -d' ' -f 3 | tr -d v 2>/dev/null)"
  fi
}

##LIST ANY NON-EMPTY SYSTEMS FOUND IN THE ROM FOLDER
function _list_systems_rgs-sr-skyscraper() {
  find -L "$romdir/" -mindepth 1 -maxdepth 1 -type d -not -empty | sort -u
}

function configure_rgs-sr-skyscraper() {
  if [[ "$md_mode" == "remove" ]]; then
    return
  fi

  ##CHECK IF THIS A FIRST TIME INSTALL
  local local_config
  local_config=$(readlink -qn "$home/.skyscraper")

  # Handle the cases where the user has an existing Skyscraper installation.
  if [[ -d "$home/.skyscraper" && "$local_config" != "$configdir/all/skyscraper" ]]; then
    ##WE HAVE AN EXISTING SKYSCRAPER INSTALLATION BUT NOT HANDLED BY THIS SCRIPTMODULE.
    ##SINCE THE $HOME/.skyscraper FOLDER WILL BE MOVED MAKE SURE THE 'cache' AND 'import' FOLDERS ARE MOVED SEPARATELY
    local f_size
    local cache_folder="dbs"
    [[ -d "$home/.skyscraper/cache" ]] && cache_folder="cache"

    f_size=$(du --total -sm "$home/.skyscraper/$cache_folder" "$home/.skyscraper/import" 2>/dev/null | tail -n 1 | cut -f 1)
    printMsgs "console" "INFO: Moving the Cache and Import folders to new configuration folder (total: $f_size Mb)"

    local folder
    for folder in $cache_folder import; do
      mv "$home/.skyscraper/$folder" "$home/.skyscraper-$folder" &&
        printMsgs "console" "INFO: Moved "$home/.skyscraper/$folder" to "$home/.skyscraper-$folder""
    done

    ##WHEN HAVING AN EXISTING INSTALLATION CHANCES ARE THE GAMELIST IS GENERATED IN THE ROMS FOLDER
    ##CREATE A GUI CONFIG FILE WITH THIS SETTING PRE-SET
    iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
    iniSet "use_rom_folder" 1
  fi

  moveConfigDir "$home/.skyscraper" "$configdir/all/skyscraper"

  ##MOVE THE CACHE AND IMPORT FOLDERS BACK THE NEW CONF FOLDER
  for folder in $cache_folder import; do
    if [[ -d "$home/.skyscraper-$folder" ]]; then
      printMsgs "console" "INFO: Moving "$home/.skyscraper-$folder" back to configuration folder"
      mv "$home/.skyscraper-$folder" "$configdir/all/skyscraper/$folder"
    fi
  done

  _init_config_rgs-sr-skyscraper
  chown -R "$user:$user" "$configdir/all/skyscraper"
}

function _init_config_rgs-sr-skyscraper() {
  local scraper_conf_dir="$configdir/all/skyscraper"

  ##MAKE SURE THE `artwork.xml` AND OTHER CONF FILE(S) ARE PRESENT BUT DON'T OVERWRITE THEM ON UPGRADES
  local f_conf
  for f_conf in artwork.xml aliasMap.csv; do
    if [[ -f "$scraper_conf_dir/$f_conf" ]]; then
      cp -f "$md_inst/share/skyscraper/$f_conf" "$scraper_conf_dir/$f_conf.default"
    else
      cp "$md_inst/share/skyscraper/$f_conf" "$scraper_conf_dir"
    fi
  done

  ##IF WE DON'T HAVE A PREVIOUS config.ini FILE COPY THE EXAMPLE ONE
  [[ ! -f "$scraper_conf_dir/config.ini" ]] && cp "$md_inst/share/skyscraper/config.ini.example" "$scraper_conf_dir/config.ini"

  ##COPY REQUIRED FILES
  cp -rf "$md_inst/share/skyscraper/" "$scraper_conf_dir"

  ##CREATE THE IMPORT FOLDERS
  local folder
  for folder in covers marquees screenshots textual videos wheels; do
    mkUserDir "$scraper_conf_dir/import/$folder"
  done
}

##SCRAPE ONE SYSTEM PASSED AS PARAMETER
function _scrape_rgs-sr-skyscraper() {
  local system="$1"

  [[ -z "$system" ]] && return

  iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
  eval "$(_load_config_rgs-sr-skyscraper)"

  local -a params=(-i "$romdir/$system" -p "$system")
  local flags="unattend,skipped,"

  [[ "$download_videos" -eq 1 ]] && flags+="videos,"

  [[ "$cache_marquees" -eq 0 ]] && flags+="nomarquees,"

  [[ "$cache_covers" -eq 0 ]] && flags+="nocovers,"

  [[ "$cache_screenshots" -eq 0 ]] && flags+="noscreenshots,"

  [[ "$cache_wheels" -eq 0 ]] && flags+="nowheels,"

  [[ "$only_missing" -eq 1 ]] && flags+="onlymissing,"

  [[ "$rom_name" -eq 1 ]] && flags+="forcefilename,"

  [[ "$remove_brackets" -eq 1 ]] && flags+="nobrackets,"

  if [[ "$use_rom_folder" -eq 1 ]]; then
    params+=(-g "$romdir/$system")
    params+=(-o "$romdir/$system/media")
    ##IF WE'RE SAVING TO THE ROM FOLDER, THEN USE RELATIVE PATHS IN THE GAMELIST
    flags+="relative,"
  else
    params+=(-g "$home/.emulationstation/gamelists/$system")
    params+=(-o "$home/.emulationstation/downloaded_media/$system")
  fi

  ##IF 2ND PARAMETER IS UNSET USE THE CONFIGURED SCRAPING SOURCE OTHERWISE SCRAPE FROM CACHE
  ##SCRAPING FROM CACHE MEANS WE CAN OMIT '-S' FROM THE PARAMETER LIST
  if [[ -z "$2" ]]; then
    params+=(-s "$scrape_source")
  fi

  [[ "$force_refresh" -eq 1 ]] && params+=(--refresh)

  ##THERE WILL ALWAYS BE A ',' AT THE END OF $flags REMOVE IT
  flags=${flags::-1}

  params+=(--flags "$flags")

  ##TRAP CTRL+C AND RETURN IF PRESSED (RATHER THAN EXITING ARCH-RGS)
  trap 'trap 2; return 1' INT
  sudo -u "$user" stdbuf -o0 "$md_inst/bin/Skyscraper" "${params[@]}"
  echo -e "\nCOMMAND LINE USED:\n $md_inst/bin/Skyscraper" "${params[@]}"
  sleep 2
  trap 2
}

##SCRAPE A LIST OF SYSTEMS CHOSEN BY THE USER
function _scrape_chosen_rgs-sr-skyscraper() {
  local options=()
  local system
  local i=1

  while read system; do
    system=${system/$romdir\//}
    options+=($i "$system" OFF)
    ((i++))
  done < <(_list_systems_rgs-sr-skyscraper)

  if [[ ${#options[@]} -eq 0 ]]; then
    printMsgs "dialog" "No populated ROM folders were found in $romdir."
    return
  fi

  local choices
  local cmd=(dialog --backtitle "$__backtitle" --ok-label "Start" --cancel-label "Back" --checklist " Select platforms for resource gathering\n\n" 22 60 16)

  choices=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

  ##EXIT IF NOTHING WAS CHOSEN OR CANCEL WAS USED
  [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

  ##CONFIRM WITH THE USER THAT SCRAPING CAN START
  dialog --clear --colors --yes-label "Proceed" --no-label "Abort" --yesno "This will start the gathering process, which can take a long time if you have a large game collection.\n\nYou can interrupt this process anytime by pressing \ZbCtrl+C\Zn.\nProceed ?" 12 70 2>&1 >/dev/tty
  [[ ! $? -eq 0 ]] && return 1

  local choice

  for choice in "${choices[@]}"; do
    choice="${options[choice * 3 - 2]}"
    _scrape_rgs-sr-skyscraper "$choice" "$@"
  done
}

##GENERATE GAMELISTS FOR A LIST OF SYSTEMS CHOSEN BY THE USER
function _generate_chosen_rgs-sr-skyscraper() {
  local options=()
  local system
  local i=1

  while read system; do
    system=${system/$romdir\//}
    options+=("$i" "$system" OFF)
    ((i++))
  done < <(_list_systems_rgs-sr-skyscraper)

  if [[ ${#options[@]} -eq 0 ]]; then
    printMsgs "dialog" "No populated ROM folders were found in $romdir."
    return
  fi

  local choices
  local cmd=(dialog --backtitle "$__backtitle" --ok-label "Start" --cancel-label "Back" --checklist " Select platforms for gamelist(s) generation\n\n" 22 60 16)

  choices="($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))"

  ##EXIT IF NOTHING WAS CHOSEN OR CANCEL WAS USED
  [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

  for choice in "${choices[@]}"; do
    choice="${options[choice * 3 - 2]}"
    _scrape_rgs-sr-skyscraper "$choice" "cache" "$@"
  done
}

function _load_config_rgs-sr-skyscraper() {
  printf '%s\n' \
    "$(
      loadModuleConfig \
        'rom_name=0' \
        'use_rom_folder=0' \
        'download_videos=0' \
        'cache_marquees=1' \
        'cache_covers=1' \
        'cache_wheels=1' \
        'cache_screenshots=1' \
        'scrape_source=screenscraper' \
        'remove_brackets=0' \
        'force_refresh=0' \
        'only_missing=0'
    )"
}

function _open_editor_rgs-sr-skyscraper() {
  local editor
  editor="${EDITOR:-nano}"
  sudo -u "$user" "$editor" "$1" >/dev/tty </dev/tty
}

function _gui_advanced_rgs-sr-skyscraper() {
  declare -A help_strings_adv

  iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
  eval "$(_load_config_rgs-sr-skyscraper)"

  help_strings_adv=(
    [E]="Opens the configuration file \Zbconfig.ini\Zn in an editor."
    [F]="Opens the artwork definition file \Zbartwork.xml\Zn in an editor."
    [G]="Opens the game alias configuration file \ZbaliasMap.csv\Zn in an editor."
  )

  while true; do

    local cmd=(dialog --backtitle "$__backtitle" --help-button --colors --no-collapse --default-item "$default" --ok-label "Ok" --cancel-label "Back" --title "Advanced options" --menu "    EXPERT - edit configurations\n" 14 50 5)
    local options=()

    options+=(E "Edit 'config.ini'")
    options+=(F "Edit 'artwork.xml'")
    options+=(G "Edit 'aliasMap.csv'")

    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [[ -n "$choice" ]]; then
      local default="$choice"

      case "$choice" in

      E)
        _open_editor_rgs-sr-skyscraper "$configdir/all/skyscraper/config.ini"
        ;;

      F)
        _open_editor_rgs-sr-skyscraper "$configdir/all/skyscraper/artwork.xml"
        ;;

      G)
        _open_editor_rgs-sr-skyscraper "$configdir/all/skyscraper/aliasMap.csv"
        ;;

      HELP*)
        ##RETAIN CHOICE
        default="${choice/HELP /}"
        if [[ -n "${help_strings_adv[${default}]}" ]]; then
          dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_adv[${default}]}" 22 65 >&1
        fi
        ;;
      esac
    else
      break
    fi
  done
}

function gui_rgs-sr-skyscraper() {
  if pgrep "emulationstatio" >/dev/null; then
    printMsgs "dialog" "This scraper must not be run while EmulationStation is running or the scraped data will be overwritten.\n\nPlease quit EmulationStation and run Arch-RGS from the terminal:\n\n sudo \$HOME/arch-rgs/archrgs_setup.sh"
    return
  fi

  iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
  eval "$(_load_config_rgs-sr-skyscraper)"
  chown "$user":"$user" "$configdir/all/skyscraper.cfg"

  local -a s_source
  local -a s_source_names
  declare -A help_strings

  s_source=(
    [1]=screenscraper
    [2]=arcadedb
    [3]=thegamesdb
    [4]=openretro
    [5]=worldofspectrum
  )
  s_source+=(
    [10]=esgamelist
    [11]=import
  )

  s_source_names=(
    [1]=ScreenScraper
    [2]=ArcadeDB
    [3]=TheGamesDB
    [4]=OpenRetro
    [5]="World of Spectrum"
  )
  s_source_names+=(
    [10]="EmulationStation Gamelist"
    [11]="Import Folder"
  )

  ##HELP STRINGS FOR THIS GUI
  help_strings=(
    [1]="Gather resources and cache them for the platforms found in \Zb$romdir\Zn.\nRuns the scraper to download the information and media from the selected gathering source."
    [2]="Select the source for ROM scraping. Supported sources:\n\ZbONLINE\Zn\n * ScreenScraper (screenscraper.fr)\n * TheGamesDB (thegamesdb.net)\n * OpenRetro (openretro.org)\n * ArcadeDB (adb.arcadeitalia.net)\n * World of Spectrum (worldofspectrum.org)\n\ZbLOCAL\Zn\n * EmulationStation Gamelist (imports data from ES gamelist)\n * Import (imports resources in the local cache)\n\n\Zb\ZrNOTE\Zn: Some sources require a username and password for access. These can be set per source in the \Zbconfig.ini\Zn configuration file.\n\n Skyscraper parameter: \Zb-s <source_name>\Zn"
    [3]="Options for resource gathering and caching sub-menu.\nClick to open it."
    [4]="Generate EmulationStation game lists.\nRuns the scraper to incorporate downloaded information and media from the local cache and write them to \Zbgamelist.xml\Zn files to be used by EmulationStation."
    [5]="Options for EmulationStation game list generation sub-menu.\nClick to open it and change the options."
    [V]="Toggle the download and caching of videos.\nThis also toggles whether the videos will be included in the resulting gamelist.\n\nSkyscraper option: \Zb--flags videos\Zn"
    [A]="Advanced options sub-menu."
  )

  while true; do

    local cmd=(dialog --backtitle "$__backtitle" --colors --cancel-label "Exit" --help-button --no-collapse --cr-wrap --default-item "$default" --menu "   Skyscraper: A Game Scraper by Lars Muldjord\\n \\n" 22 60 12)

    local options=(
      "-" "GATHER and cache resources"
    )

    local source_found=0
    local online="Online"
    local i

    options+=(
      1 "Gather resources"
    )

    for i in "${!s_source[@]}"; do
      if [[ "$scrape_source" == "${s_source[$i]}" ]]; then
        [[ $i -ge 10 ]] && online="Local"
        options+=(2 "Gather source - ${s_source_names[$i]} ($online) -->")
        source_found=1
      fi
    done

    if [[ $source_found -ne 1 ]]; then
      options+=(2 "Gather from - Screenscraper (Online) -->")
      scrape_source="screenscraper"
      iniSet "scrape_source" "$scrape_source"
    fi

    options+=(3 "Cache options and commands -->")

    options+=("-" "GAME LIST generation")
    options+=(4 "Generate game list(s)")
    options+=(5 "Generate options -->")

    options+=("-" "OTHER options")

    if [[ "$download_videos" -eq 1 ]]; then
      options+=(V "Download videos (Enabled)")
    else
      options+=(V "Download videos (Disabled)")
    fi

    options+=(A "Advanced options -->")

    ##RUN THE GUI
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [[ -n "$choice" ]]; then
      local default="$choice"

      case "$choice" in

      1)
        if _scrape_chosen_rgs-sr-skyscraper; then
          printMsgs "dialog" "ROMs information gathered.\nDon't forget to use 'Generate Game list(s)' to add this information to EmulationStation."
        elif [[ $? -eq 2 ]]; then
          printMsgs "dialog" "Gathering was aborted"
        fi
        ;;

      2)
        ##SCRAPE SOURCE OPTIONS HAVE A SEPARATE DIALOG
        local s_options=()
        local i

        for i in "${!s_source[@]}"; do
          online="Online:"
          [[ i -ge 10 ]] && online="Local:"

          if [[ "$scrape_source" == "${s_source[$i]}" ]]; then
            s_default="$online ${s_source_names[$i]}"
          fi

          s_options+=("$online ${s_source_names[$i]}" "")
        done

        if [[ -z "$s_default" ]]; then
          s_default="Online: ${s_source_names[1]}"
        fi

        local s_cmd=(dialog --title "Select Scraping source" --default-item "$s_default"
          --menu "Choose one of the available scraping sources" 18 50 9)

        ##RUN THE SCRAPER SOURCE SELECTION DIALOG
        local scrape_source_name
        scrape_source_name=$("${s_cmd[@]}" "${s_options[@]}" 2>&1 >/dev/tty)

        ##IF CANCEL WAS CHOSEN DO NOT DO ANYTHING
        [[ -z "$scrape_source_name" ]] && continue

        ##STRIP THE "XYZ:" PREFIX FROM THE CHOSEN SCRAPER SOURCE THEN COMPARE TO OUR LIST
        local src
        src=$(echo "$scrape_source_name" | cut -d' ' -f2-)

        for i in "${!s_source_names[@]}"; do
          [[ "${s_source_names[$i]}" == "$src" ]] && scrape_source=${s_source[$i]}
        done

        iniSet "scrape_source" "$scrape_source"
        ;;

      3)
        _gui_cache_rgs-sr-skyscraper
        ;;

      4)
        if _generate_chosen_rgs-sr-skyscraper "cache"; then
          printMsgs "dialog" "Game list(s) generated."
        elif [[ $? -eq 2 ]]; then
          printMsgs "dialog" "Game list generation aborted"
        fi
        ;;

      5)
        _gui_generate_rgs-sr-skyscraper
        ;;

      V)
        download_videos="$((download_videos ^ 1))"
        iniSet "download_videos" "$download_videos"
        ;;

      A)
        _gui_advanced_rgs-sr-skyscraper
        ;;

      HELP*)
        ##RETAIN CHOICE WHEN THE HELP BUTTON IS SELECTED
        default="${choice/HELP /}"
        if [[ ! -z "${help_strings[$default]}" ]]; then
          dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings[$default]}" 22 65 >&1
        fi
        ;;
      esac
    else
      break
    fi
  done
}

function _gui_cache_rgs-sr-skyscraper() {
  local db_size
  local cache_folder
  declare -A help_strings_cache
  cache_folder=$(_cache_folder_rgs-sr-skyscraper)

  iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
  eval "$(_load_config_rgs-sr-skyscraper)"

  help_strings_cache=(
    [1]="Toggle whether screenshots are cached locally when scraping.\n\nSkyscraper option: \Zb--flags noscreenshots\Zn"
    [2]="Toggle whether covers are cached locally when scraping.\n\nSkyscraper option: \Zb--flags nocovers\Zn"
    [3]="Toggle whether wheels are cached locally when scraping.\n\nSkyscraper option: \Zb--flags nowheels\Zn"
    [4]="Toggle whether marquees are cached locally when scraping.\n\nSkyscraper option: \Zb--flags nomarquees\Zn"
    [5]="Enable this to only scrape files that do not already have data in the Skyscraper resource cache.\n\nSkyscraper option: \Zb--flags onlymissing\Zn"
    [6]="Force the refresh of resources in the local cache when scraping.\n\nSkyscraper option: \Zb--cache refresh\Zn"
    [P]="Purge \ZbALL\Zn all cached resources for all platforms."
    [S]="Purge all cached resources for a chosen platform.\n\nSkyscraper option: \Zb--cache purge:all\Zn"
    [V]="Removes all non-used cached resources for a chosen platform (vacuum).\n\nSkyscraper option: \Zb--cache vacuum\Zn"
  )

  while true; do
    db_size=$(du -sh "$configdir/all/skyscraper/$cache_folder" 2>/dev/null | cut -f 1 || echo 0m)
    [[ -z "$db_size" ]] && db_size="0Mb"

    local cmd=(dialog --backtitle "$__backtitle" --help-button --colors --no-collapse --default-item "$default" --ok-label "Ok" --cancel-label "Back" --title "Cache options and commands" --menu "\n               Current cache size: $db_size\n\n" 21 60 12)

    local options=("-" "OPTIONS for gathering and caching")

    if [[ "$cache_screenshots" -eq 1 ]]; then
      options+=(1 "Cache screenshots (Enabled)")
    else
      options+=(1 "Cache screenshots (Disabled)")
    fi

    if [[ "$cache_covers" -eq 1 ]]; then
      options+=(2 "Cache covers (Enabled)")
    else
      options+=(2 "Cache covers (Disabled)")
    fi

    if [[ "$cache_wheels" -eq 1 ]]; then
      options+=(3 "Cache wheels (Enabled)")
    else
      options+=(3 "Cache wheels (Disabled)")
    fi

    if [[ "$cache_marquees" -eq 1 ]]; then
      options+=(4 "Cache marquees (Enabled)")
    else
      options+=(4 "Cache marquees (Disabled)")
    fi

    if [[ "$only_missing" -eq 1 ]]; then
      options+=(5 "Scrape only missing (Enabled)")
    else
      options+=(5 "Scrape only missing (Disabled)")
    fi

    if [[ "$force_refresh" -eq 0 ]]; then
      options+=(6 "Force cache refresh (Disabled)")
    else
      options+=(6 "Force cache refresh (Enabled)")
    fi

    options+=("-" "PURGE cache commands")
    options+=(V "Vacuum chosen platform")
    options+=(S "Purge chosen platform")
    options+=(P "Purge all platforms(!)")

    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [[ -n "$choice" ]]; then
      local default="$choice"

      case "$choice" in

      1)
        cache_screenshots="$((cache_screenshots ^ 1))"
        iniSet "cache_screenshots" "$cache_screenshots"
        ;;

      2)
        cache_covers="$((cache_covers ^ 1))"
        iniSet "cache_covers" "$cache_covers"
        ;;

      3)
        cache_wheels="$((cache_wheels ^ 1))"
        iniSet "cache_wheels" "$cache_wheels"
        ;;

      4)
        cache_marquees="$((cache_marquees ^ 1))"
        iniSet "cache_marquees" "$cache_marquees"
        ;;

      5)
        only_missing="$((only_missing ^ 1))"
        iniSet "only_missing" "$only_missing"
        ;;

      6)
        force_refresh="$((force_refresh ^ 1))"
        iniSet "force_refresh" "$force_refresh"
        ;;

      V)
        _purge_platform_rgs-sr-skyscraper "vacuum"
        ;;

      S)
        _purge_platform_rgs-sr-skyscraper
        ;;

      P)
        dialog --clear --defaultno --colors --yesno "\Z1\ZbAre you sure ?\Zn\nThis will \Zb\ZuERASE\Zn all locally cached scraped resources" 8 60 2>&1 >/dev/tty
        if [[ $? == 0 ]]; then
          _purge_rgs-sr-skyscraper
        fi
        ;;

      HELP*)
        ##RETAIN CHOICE
        default="${choice/HELP /}"
        if [[ -n "${help_strings_cache[${default}]}" ]]; then
          dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_cache[${default}]}" 22 65 >&1
        fi
        ;;
      esac
    else
      break
    fi
  done
}

function _gui_generate_rgs-sr-skyscraper() {
  declare -A help_strings_gen

  iniConfig " = " '"' "$configdir/all/skyscraper.cfg"
  eval "$(_load_config_rgs-sr-skyscraper)"

  help_strings_gen=(
    [1]="Game name format used in the EmulationStation game list. Available options:\n\n\ZbSource name\Zn: use the name returned by the scraper\n\ZbFilename\Zn: use the filename of the ROM as game name\n\nSkyscraper option: \Zb--flags forcefilename\Z0"
    [2]="Game name option to remove/keep the text found between '()' and '[]' in the ROMs filename.\n\nSkyscraper option: \Zb--flags nobrackets\Zn"
    [3]="Choose to save the generated 'gamelist.xml' and media in the ROMs folder. Supported options:\n\n\ZbEnabled\Zn saves the 'gamelist.xml' in the ROMs folder and the media in the 'media' sub-folder.\n\n\ZbDisabled\Zn saves the 'gamelist.xml' in \Zu\$HOME/.emulationstation/gamelists/<system>\Zn and the media in \Zu\$HOME/.emulationstation/downloaded_media\Zn.\n\n\Zb\ZrNOTE\Zn: changing this option will not automatically copy the 'gamelist.xml' file and the media to the new location or remove the ones in the old location. You must do this manually.\n\nSkyscraper parameters: \Zb-g <gamelist>\Zn / \Zb-o <path>\Zn"
  )

  while true; do

    local cmd=(dialog --backtitle "$__backtitle" --help-button --colors --no-collapse --default-item "$default" --ok-label "Ok" --cancel-label "Back" --title "Game list generation options" --menu "\n\n" 13 60 5)
    local -a options

    if [[ "$rom_name" -eq 0 ]]; then
      options=(1 "ROM Names (Source name)")
    else
      options=(1 "ROM Names (Filename)")
    fi

    if [[ "$remove_brackets" -eq 1 ]]; then
      options+=(2 "Remove bracket info (Enabled)")
    else
      options+=(2 "Remove bracket info (Disabled)")
    fi

    if [[ "$use_rom_folder" -eq 1 ]]; then
      options+=(3 "Use ROM folders for game list & media (Enabled)")
    else
      options+=(3 "Use ROM folders for game list & media (Disabled)")
    fi

    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [[ -n "$choice" ]]; then
      local default="$choice"

      case "$choice" in

      1)
        rom_name="$((rom_name ^ 1))"
        iniSet "rom_name" "$rom_name"
        ;;

      2)
        remove_brackets="$((remove_brackets ^ 1))"
        iniSet "remove_brackets" "$remove_brackets"
        ;;

      3)
        use_rom_folder="$((use_rom_folder ^ 1))"
        iniSet "use_rom_folder" "$use_rom_folder"
        ;;

      HELP*)
        ##RETAIN CHOICE
        default="${choice/HELP /}"
        if [[ ! -z "${help_strings_gen[${default}]}" ]]; then
          dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_gen[${default}]}" 22 65 >&1
        fi
        ;;
      esac
    else
      break
    fi
  done
}


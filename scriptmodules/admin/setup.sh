#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

archrgs_module_id="setup"
archrgs_module_desc="GUI Based Setup For Arch-RGS"
archrgs_module_section=""

function _setup_gzip_log() {
  setsid tee >(setsid gzip --stdout >"$1")
}

function archrgs_logInit() {
  if [[ ! -d "$__logdir" ]]; then
    if mkdir -p "$__logdir"; then
      chown "$user:$user" "$__logdir"
    else
      fatalError "Couldn't make directory $__logdir"
    fi
  fi
  local now
  now=$(date +'%Y-%m-%d_%H%M%S')
  logfilename="$__logdir/archrgs_$now.log.gz"
  touch "$logfilename"
  chown "$user:$user" "$logfilename"
  time_start=$(date +"%s")
}

function archrgs_logStart() {
  echo -e "Log Started At: $(date -d @"$time_start")\n"
  echo "Arch-RGS Setup Version: $__version ($(git -C "$scriptdir" log -1 --pretty=format:%h))"
  echo "System: $__platform $__os_desc - $(uname -a)"
}

function archrgs_logEnd() {
  time_end=$(date +"%s")
  echo
  echo "Log Ended At: $(date -d @"$time_end")"
  date_total=$((time_end - time_start))
  local hours=$((date_total / 60 / 60 % 24))
  local mins=$((date_total / 60 % 60))
  local secs=$((date_total % 60))
  echo "Total Running Time: $hours Hours, $mins Mins, $secs Secs"
}

function archrgs_printInfo() {
  local log="$1"
  reset
  if [[ ${#__ERRMSGS[@]} -gt 0 ]]; then
    printMsgs "dialog" "${__ERRMSGS[@]}"
    [[ -n "$log" ]] && printMsgs "dialog" "Please See $log For More In-Depth Information Regarding the Errors."
  fi
  if [[ ${#__INFMSGS[@]} -gt 0 ]]; then
    printMsgs "dialog" "${__INFMSGS[@]}"
  fi
  __ERRMSGS=()
  __INFMSGS=()
}

function depends_setup() {
  ##CHECK FOR VERSION FILE
  if [[ ! -f "$rootdir/VERSION" ]]; then
    joy2keyStop
    exec "$scriptdir/archrgs_packages.sh" setup post_update gui_setup
  fi

  ##REMOVE ALL BUT THE LAST 20 LOGS
  find "$__logdir" -type f | sort | head -n -20 | xargs -d '\n' --no-run-if-empty rm
}

function updatescript_setup() {
  clear
  chown -R "$user:$user" "$scriptdir"
  printHeading "Fetching latest version of the Arch-RGS Setup Script."
  pushd "$scriptdir" >/dev/null || exit
  if [[ ! -d ".git" ]]; then
    printMsgs "dialog" "Cannot find directory '.git'. Please clone the Arch-RGS Setup script via 'git clone https://gitlab.com/arch-rgs/arch-rgs.git'"
    popd >/dev/null || exit
    return 1
  fi
  local error
  if ! error=$(su "$user" -c "git pull 2>&1 >/dev/null"); then
    printMsgs "dialog" "Update failed:\n\n$error"
    popd >/dev/null || exit
    return 1
  fi
  popd >/dev/null || exit

  printMsgs "dialog" "Fetched the latest version of the Arch-RGS Setup script."
  return 0
}

function post_update_setup() {
  local return_func=("$@")

  joy2keyStart

  echo "$__version" >"$rootdir/VERSION"

  clear
  local logfilename
  archrgs_logInit
  {
    archrgs_logStart
    printHeading "Running post update hooks"
    archrgs_updateHooks
    archrgs_logEnd
  } &> >(_setup_gzip_log "$logfilename")
  archrgs_printInfo "$logfilename"

  printMsgs "dialog" "NOTICE: The Arch-RGS Setup Script Is Available To Download For Free From:\n\nhttps://gitlab.com/arch-rgs/arch-rgs.git.\n\nArch-RGS Includes Software That Has Non Commercial Licences. Selling Or Including Arch-RGS With Your Commercial Product Is Not Allowed.\n\nNo Copyrighted Games Are Included With Arch-RGS.\n\nIf You Have Been Sold This Software, You Can Report It By Emailing archrgs.project@gmail.com."

  ##Return To Set Return Function
  "${return_func[@]}"
}

function package_setup() {
  local idx="$1"
  local md_id="${__mod_id[$idx]}"

  while true; do
    local options=()
    local install
    local status
    if archrgs_isInstalled "$idx"; then
      install="Update"
      status="Installed"
    else
      install="Install"
      status="Not installed"
    fi

    if archrgs_hasPackage "$idx"; then
      options+=(I "$install From Package")
    fi

    if fnExists "sources_${md_id}"; then
      options+=(S "$install From Source")
    fi

    if archrgs_isInstalled "$idx"; then
      if fnExists "gui_${md_id}"; then
        options+=(C "Configuration & Options")
      fi
      options+=(X "Remove")
    fi

    if [[ -d "$__builddir/$md_id" ]]; then
      options+=(Z "Clean Source Folder")
    fi

    local help="${__mod_desc[$idx]}\n\n${__mod_help[$idx]}"
    if [[ -n "$help" ]]; then
      options+=(H "Package Help")
    fi

    cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --menu "Choose An Option For ${__mod_id[$idx]}\n$status" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    local logfilename

    case "$choice" in
    I)
      clear
      archrgs_logInit
      {
        archrgs_logStart
        archrgs_installModule "$idx"
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    S)
      clear
      archrgs_logInit
      {
        archrgs_logStart
        archrgs_callModule "$idx" clean
        archrgs_callModule "$idx"
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    C)
      archrgs_logInit
      {
        archrgs_logStart
        archrgs_callModule "$idx" gui
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    X)
      local text="Are You Sure You Want to Remove $md_id?"
      [[ "${__mod_section[$idx]}" == "core" ]] && text+="\n\nWARNING! - Core Packages Are Needed For Arch-RGS to Function!"
      dialog --defaultno --yesno "$text" 22 76 >/dev/tty 2>&1 || continue
      archrgs_logInit
      {
        archrgs_logStart
        archrgs_callModule "$idx" remove
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    H)
      printMsgs "dialog" "$help"
      ;;
    Z)
      archrgs_callModule "$idx" clean
      printMsgs "dialog" "$__builddir/$md_id has been removed."
      ;;
    *)
      break
      ;;
    esac

  done
}

function section_gui_setup() {
  local section="$1"

  local default=""
  while true; do
    local options=()

    options+=(
      I "Install/Update All ${__sections[$section]} packages" "I This Will Install All ${__sections[$section]} Packages Via makepkg."
      X "Remove All ${__sections[$section]} packages" "X This Will Remove All $section Packages."
    )

    local idx
    for idx in $(archrgs_getSectionIds "$section"); do
      if archrgs_isInstalled "$idx"; then
        installed="(Installed)"
      else
        installed=""
      fi
      options+=("$idx" "${__mod_id[$idx]} $installed" "$idx ${__mod_desc[$idx]}"$'\n\n'"${__mod_help[$idx]}")
    done

    local cmd=(dialog --colors --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break
    if [[ "${choice[*]:0:4}" == "HELP" ]]; then
      ##Remove Help
      choice="${choice[*]:5}"
      ##Get Id Of Menu Item
      default="${choice/%\ */}"
      ##Remove Id
      choice="${choice#* }"
      printMsgs "dialog" "$choice"
      continue
    fi

    default="$choice"

    local logfilename
    case "$choice" in
    I)
      dialog --defaultno --yesno "Are You Sure You Want to Install/Update All $section Packages Via makepkg?" 22 76 >/dev/tty 2>&1 || continue
      archrgs_logInit
      {
        archrgs_logStart
        for idx in $(archrgs_getSectionIds "$section"); do
          archrgs_installModule "$idx"
        done
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    S)
      dialog --defaultno --yesno "Are You Sure You Want to Install/Update All $section Packages From Source?" 22 76 >/dev/tty 2>&1 || continue
      archrgs_logInit
      {
        archrgs_logStart
        for idx in $(archrgs_getSectionIds "$section"); do
          archrgs_callModule "$idx" clean
          archrgs_callModule "$idx"
        done
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;

    X)
      local text="Are You Sure You Want to Remove All $section Packages?"
      [[ "$section" == "core" ]] && text+="\n\nWARNING! - Core Packages Are Needed For Arch-RGS to Function!"
      dialog --defaultno --yesno "$text" 22 76 >/dev/tty 2>&1 || continue
      archrgs_logInit
      {
        archrgs_logStart
        for idx in $(archrgs_getSectionIds "$section"); do
          archrgs_isInstalled "$idx" && archrgs_callModule "$idx" remove
        done
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    *)
      package_setup "$choice"
      ;;
    esac

  done
}

function config_gui_setup() {
  local default
  while true; do
    local options=()
    local idx
    for idx in "${__mod_idx[@]}"; do
      ##Show All Configuration Modules and Any Installed Packages With a GUI Function
      if [[ "${__mod_section[idx]}" == "config" ]] || archrgs_isInstalled "$idx" && fnExists "gui_${__mod_id[idx]}"; then
        options+=("$idx" "${__mod_id[$idx]}  - ${__mod_desc[$idx]}" "$idx ${__mod_desc[$idx]}")
      fi
    done

    local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break
    if [[ "${choice[*]:0:4}" == "HELP" ]]; then
      choice="${choice[*]:5}"
      default="${choice/%\ */}"
      choice="${choice#* }"
      printMsgs "dialog" "$choice"
      continue
    fi

    [[ -z "$choice" ]] && break

    default="$choice"

    local logfilename
    archrgs_logInit
    {
      archrgs_logStart
      if fnExists "gui_${__mod_id[choice]}"; then
        archrgs_callModule "$choice" depends
        archrgs_callModule "$choice" gui
      else
        archrgs_callModule "$idx" clean
        archrgs_callModule "$choice"
      fi
      archrgs_logEnd
    } &> >(_setup_gzip_log "$logfilename")
    archrgs_printInfo "$logfilename"
  done
}

function update_packages_setup() {
  clear
  local idx
  for idx in "${__mod_idx[@]}"; do
    if archrgs_isInstalled "$idx" && [[ -n "${__mod_section[$idx]}" ]]; then
      archrgs_installModule "$idx"
    fi
  done
}

function update_packages_gui_setup() {
  local update="$*"
  if [[ "$update" != "update" ]]; then
    dialog --defaultno --yesno "Are You Sure You Want To Update Installed Packages?" 22 76 >/dev/tty 2>&1 || return 1
    updatescript_setup || return 1
    ##Restart At Post_update And Then Call "update_packages_gui_setup update" Afterwards
    joy2keyStop
    exec "$scriptdir/archrgs_packages.sh" setup post_update update_packages_gui_setup update
  fi

  local update_os=0
  dialog --yesno "Would You Like To Update Arch Linux?" 22 76 >/dev/tty 2>&1 && update_os=1

  clear

  local logfilename
  archrgs_logInit
  {
    archrgs_logStart
    [[ "$update_os" -eq 1 ]] && pacmanUpdate
    update_packages_setup
    archrgs_logEnd
  } &> >(_setup_gzip_log "$logfilename")

  archrgs_printInfo "$logfilename"
  printMsgs "dialog" "Installed Packages Have Been Updated."
  gui_setup "$@"
}

function basic_install_setup() {
  local idx
  for idx in $(archrgs_getSectionIds core); do
    archrgs_installModule "$idx" || return 1
  done
  return 0
}

function packages_gui_setup() {
  local section
  local default
  local options=()

  for section in core emulators libretrocores ports frontends driver exp; do
    options+=("$section" "Manage ${__sections[$section]} Packages" "$section Choose To Install/Update/Configure Packages From The ${__sections[$section]}")
  done

  local cmd
  while true; do
    cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break
    if [[ "${choice[*]:0:4}" == "HELP" ]]; then
      choice="${choice[*]:5}"
      default="${choice/%\ */}"
      choice="${choice#* }"
      printMsgs "dialog" "$choice"
      continue
    fi
    section_gui_setup "$choice"
    default="$choice"
  done
}

function uninstall_setup() {
  dialog --defaultno --yesno "Are You Sure You Want To Uninstall Arch-RGS?" 22 76 >/dev/tty 2>&1 || return 0
  dialog --defaultno --yesno "Are You REALLY Sure You Want To Uninstall Arch-RGS?\n\n$rootdir will be removed - this includes configuration files for all Arch-RGS components." 22 76 >/dev/tty 2>&1 || return 0
  clear
  printHeading "Uninstalling Arch-RGS"
  for idx in "${__mod_idx[@]}"; do
    archrgs_isInstalled "$idx" && archrgs_callModule "$idx" remove
  done
  rm -rfv "$rootdir"
  dialog --defaultno --yesno "Do You Want To Remove All The Files From $datadir - This Includes All Your Installed ROMs, BIOS Files And Custom Splashscreens." 22 76 >/dev/tty 2>&1 && rm -rfv "$datadir"
  printMsgs "dialog" "Arch-RGS Has Been Uninstalled."
}

function reboot_setup() {
  clear
  reboot
}

##Arch-RGS Setup Main Menu
function gui_setup() {
  joy2keyStart
  depends_setup
  local commit
  local default
  while true; do
    commit=$(git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

    cmd=(dialog --backtitle "$__backtitle" --title "Arch-RGS Setup Script" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Version: $__version\nLast Commit: $commit" 22 76 16)
    options=(
      I "Basic Install" "I This Will Install All Packages From Core Which Gives A Basic Arch-RGS Install. Further Packages Can Then Be Installed Later From The Emulators, Ports, Libretrocores and Experimental sections. Packages Will Be Built From Source And Installed Via makepkg."

      U "Update" "U Updates Arch-RGS Setup And All Currently Installed Packages. Will Also Update OS Packages. Packages Will Be Built And Installed Via makepkg."

      P "Manage Packages" "P Install/Remove And Configure The Various Components Of Arch-RGS, Including Emulators, Ports, And Controller Drivers."

      C "Configuration & Tools" "C Configuration and Tools. Any Packages You Have Installed That Have Additional Configuration Options Will Also Appear Here."

      S "Update Arch-RGS Setup Script" "S Update the Arch-RGS Setup Script. This Will Update The Main Management Script Only, But Will Not Update Any Software Packages. To Update Packages Use The 'Update' Option From The Main Menu, Which Will Also Update The Arch-RGS Setup Script."

      X "Uninstall Arch-RGS" "X Uninstall Arch-RGS Completely."

      R "Perform Reboot" "R Reboot Your Machine."
    )

    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && break

    if [[ "${choice[*]:0:4}" == "HELP" ]]; then
      choice="${choice[*]:5}"
      default="${choice/%\ */}"
      choice="${choice#* }"
      printMsgs "dialog" "$choice"
      continue
    fi
    default="$choice"

    case "$choice" in
    I)
      dialog --defaultno --yesno "Are You Sure You Want To Do A Basic Install?\n\nThis Will Install All Packages From The 'Core' Package Section." 22 76 >/dev/tty 2>&1 || continue
      clear
      local logfilename
      archrgs_logInit
      {
        archrgs_logStart
        basic_install_setup
        archrgs_logEnd
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    U)
      update_packages_gui_setup "$@"
      ;;
    P)
      packages_gui_setup
      ;;
    C)
      config_gui_setup
      ;;
    S)
      dialog --defaultno --yesno "Are You Sure You Want To Update The Arch-RGS Setup Script ?" 22 76 >/dev/tty 2>&1 || continue
      if updatescript_setup; then
        joy2keyStop
        exec "$scriptdir/archrgs_packages.sh" setup post_update gui_setup
      fi
      ;;
    X)
      local logfilename
      archrgs_logInit
      {
        uninstall_setup
      } &> >(_setup_gzip_log "$logfilename")
      archrgs_printInfo "$logfilename"
      ;;
    R)
      dialog --defaultno --yesno "Are You Sure You Want To Reboot?\n\nNote That If You Reboot When Emulation Station Is Running, You Will Lose Any Metadata Changes." 22 76 >/dev/tty 2>&1 || continue
      reboot_setup
      ;;
    esac
  done
  joy2keyStop
  clear
}

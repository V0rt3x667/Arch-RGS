#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

## @file helpers.sh
## @brief Arch-RGS helpers library
## @copyright GPLv3

## @fn printMsgs()
## @param type style of display to use - dialog, console or heading
## @param message string or array of messages to display
## @brief Prints messages in a variety of ways.

function printMsgs() {
  local type="$1"
  shift
  if [[ "$__nodialog" == "1" && "$type" == "dialog" ]]; then
    type="console"
  fi
  for msg in "$@"; do
    [[ "$type" == "dialog" ]] && dialog --backtitle "$__backtitle" --cr-wrap --no-collapse --msgbox "$msg" 20 60 >/dev/tty
    [[ "$type" == "console" ]] && echo -e "$msg"
    [[ "$type" == "heading" ]] && echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$msg\n= = = = = = = = = = = = = = = = = = = = =\n"
  done
  return 0
}

## @fn printHeading()
## @param message string or array of messages to display
## @brief Calls PrintMsgs with "heading" type.
function printHeading() {
  printMsgs "heading" "$@"
}

## @fn fatalError()
## @param message string or array of messages to display
## @brief Calls PrintMsgs with "heading" type, and exits immediately.
function fatalError() {
  printHeading "Error"
  echo -e "$1"
  joy2keyStop
  exit 1
}

# @fn fnExists()
# @param name name of function to check for
# @brief Checks if function name exists.
# @retval 0 if the function name exists
# @retval 1 if the function name does not exist
function fnExists() {
  declare -f "$1" >/dev/null
  return $?
}

function ask() {
  echo -e -n "$@" '[y/n] ' ; read ans
  case "$ans" in
  y*|Y*)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

## @fn runCmd()
## @param command command to run
## @brief Calls command and record any non zero return codes for later printing.
## @return whatever the command returns.
function runCmd() {
  local ret
  "$@"
  ret=$?
  if [[ "$ret" -ne 0 ]]; then
    md_ret_errors+=("Error running '$*' - returned $ret")
  fi
  return $ret
}

## @fn hasFlag()
## @param string string to search in
## @param flag flag to search for
## @brief Checks for a flag in a string (consisting of space separated flags).
## @retval 0 if the flag was found
## @retval 1 if the flag was not found
function hasFlag() {
  local string="$1"
  local flag="$2"
  [[ -z "$string" || -z "$flag" ]] && return 1

  if [[ "$string" =~ (^| )$flag($| ) ]]; then
    return 0
  else
    return 1
  fi
}

## @fn isPlatform()
## @param platform
## @brief Test for current platform / platform flags.
function isPlatform() {
  local flag="$1"
  if hasFlag "${__platform_flags[*]}" "$flag"; then
    return 0
  fi
  return 1
}

## @fn addLineToFile()
## @param line line to add
## @param file file to add line to
## @brief Adds a new line of text to a file.
function addLineToFile() {
  if [[ -f "$2" ]]; then
    cp -p "$2" "$2.bak"
  else
    sed -i --follow-symlinks '$a\' "$2"
  fi

  echo "$1" >>"$2"
}

## @fn editFile()
## @param file file to edit
## @brief Opens an editing dialog for specified file.
function editFile() {
  local file="$1"
  local cmd
  local choice
  cmd=(dialog --backtitle "$__backtitle" --editbox "$file" 22 76)
  choice=$("${cmd[@]}" 2>&1 >/dev/tty)
  [[ -n "$choice" ]] && echo "$choice" >"$file"
}

## @fn hasPackage()
## @param package name of Arch Linux package
## @brief Test for an installed Arch Linux package
## @retval 0 if the requested package is installed
## @retval 1 if the requested package is not installed
function hasPackage() {
  local pkg="$1"

  for pkg in $pkg; do
    if [[ "$pkg" == base-devel ]]; then
      pacman -Qg "$pkg" &>/dev/null
    else
      pacman -Q "$pkg" &>/dev/null
    fi
    if [[ "$?" == 1 ]]; then
      return 1
    else
      return 0
    fi
  done
}

## @fn pacmanUpdate()
## @brief Calls pacman -Syyu (if it has not been called before).
function pacmanUpdate() {
  if [[ "$__pacman_update" != "1" ]]; then
    pacman -Syyu --noconfirm
    __pacman_update="1"
  fi
}

## @fn pacmanInstall()
## @param packages package / space separated list of packages to install
## @brief Calls pacman -S with the packages provided.
function pacmanInstall() {
  pacmanUpdate
  pacman -S "$@" --noconfirm --needed
  return $?
}

## @fn pacmanRemove()
## @param packages package / space separated list of packages to uninstall
## @brief Calls pacman -Rc with the packages provided.
function pacmanRemove() {
  pacman -Rc "$@" --noconfirm
  return $?
}

## @fn pacmanPkg()
## @param PKGBUILD to build and install
## @brief Calls makepkg -csi --noconfirm --needed with the PKGBUILD provided.
function pacmanPkg() {
  PKGBUILD="$1"
  for pkg in $PKGBUILD; do
    su -l "$user" -c 'cd '"$scriptdir/scriptmodules/$md_type/$pkg"' && \
    BUILDDIR='"$__builddir"' \
    PKGDEST='"$__builddir/$pkg"' \
    SRCDEST='"$__builddir/$pkg"' \
    SRCPKGDEST='"$__builddir/$pkg"' \
    PACKAGER="archrgs.project <archrgs.project@gmail.com>" \
    makepkg -csi --noconfirm'
  done
}

## @fn getDepends()
## @param packages package / space separated list of packages to install
## @brief Installs packages if they are not installed.
## @retval 0 on success
## @retval 1 on failure
function getDepends() {
  local required
  local packages=()
  local failed=()

  for required in "$@"; do
    if [[ "$md_mode" == "remove" ]]; then
      hasPackage "$required" && packages+=("$required")
    else
      hasPackage "$required" || packages+=("$required")
    fi
  done

  if [[ ${#packages[@]} -ne 0 ]]; then
    if [[ "$md_mode" == "remove" ]]; then
      pacman -R --noconfirm "${packages[@]}"
      return 0
    fi
    printMsgs "console" "Did not find needed package(s): ${packages[@]}. Trying to install them now."
    pacmanInstall "${packages[@]}"
    for required in "${packages[@]}"; do
      if [[ ${#failed[@]} -eq 0 ]]; then
        printMsgs "console" "Successfully installed package: $required."
      else
        md_ret_errors+=("Could not install package(s): ${failed[*]}.")
        return 1
      fi
    done
  fi
  return 0
}

## @fn gitPullOrClone()
## @param dest destination directory
## @param repo repository to clone or pull from
## @param branch branch to clone or pull from (optional)
## @param commit specific commit to checkout (optional - requires branch to be set)
## @param depth depth parameter for git. (optional)
## @brief Git clones or pulls a repository.
## @details depth parameter will default to 1 (shallow clone).
## A depth parameter of 0 will do a full clone with all history.
function gitPullOrClone() {
  local dir="$1"
  [[ -z "$dir" ]] && dir="$md_build"
  local repo="$2"
  local branch="$3"
  local commit="$4"
  local depth="$5"

  [[ -z "$repo" ]] && return 1
  [[ -z "$branch" ]] && branch="master"
  if [[ -z "$depth" && -z "$commit" ]]; then
    depth=1
  else
    depth=0
  fi

  if [[ -d "$dir/.git" ]]; then
    pushd "$dir" >/dev/null || exit
    runCmd git checkout "$branch"
    runCmd git pull --ff-only
    runCmd git submodule update --init --recursive
    popd >/dev/null || exit
  else
    local git="git clone --recursive"
    if [[ "$depth" -gt 0 ]]; then
      git+=" --depth $depth"
    fi
    git+=" --branch $branch"
    printMsgs "console" "$git \"$repo\" \"$dir\""
    runCmd $git "$repo" "$dir"
  fi

  if [[ -n "$commit" ]]; then
    printMsgs "console" "Winding back $repo->$branch to commit: #$commit"
    git -C "$dir" branch -D "$commit" &>/dev/null
    runCmd git -C "$dir" checkout -f "$commit" -b "$commit"
  fi

  branch=$(runCmd git -C "$dir" rev-parse --abbrev-ref HEAD)
  commit=$(runCmd git -C "$dir" rev-parse HEAD)
  printMsgs "console" "HEAD is now in branch '$branch' at commit '$commit'"
}

# @fn setupDirectories()
# @brief Makes sure some required archrgs directories and files are created.
function setupDirectories() {
  mkdir -p "$rootdir"
  mkUserDir "$datadir"
  mkUserDir "$romdir"
  mkUserDir "$biosdir"
  mkUserDir "$configdir"
  mkUserDir "$configdir/all"

  ##Home Folders for Configs that Modules Rely On
  mkUserDir "$home/.cache"
  mkUserDir "$home/.config"
  mkUserDir "$home/.local"
  mkUserDir "$home/.local/share"

  ##Make Sure inifuncs.sh is in Place and Updated
  mkdir -p "$rootdir/lib"
  local helper
  for helper in inifuncs.sh archivefuncs.sh; do
    if [[ ! -f "$rootdir/lib/$helper" || "$rootdir/lib/$helper" -ot "$scriptdir/scriptmodules/$helper" ]]; then
      cp --preserve=timestamps "$scriptdir/scriptmodules/$helper" "$rootdir/lib/$helper"
    fi
  done

  ##Create Template For autoconf.cfg And Make Sure It Is Owned By $user
  local config="$configdir/all/autoconf.cfg"

  if [[ ! -f "$config" ]]; then
    echo "# This file can be used to enable/disable Arch-RGS autoconfiguration features" >"$config"
  fi
  chown "$user:$user" "$config"
}

## @fn rmDirExists()
## @param dir directory to remove
## @brief Removes a directory and all contents if it exists.
function rmDirExists() {
  if [[ -d "$1" ]]; then
    rm -rf "$1"
  fi
}

## @fn mkUserDir()
## @param dir directory to create
## @brief Creates a directory owned by the current user.
function mkUserDir() {
  mkdir -p "$1"
  chown "$user:$user" "$1"
}

## @fn mkRomDir()
## @param dir rom directory to create
## @brief Creates a directory under $romdir owned by the current user.
function mkRomDir() {
  mkUserDir "$romdir/$1"
  if [[ "$1" == "megadrive" ]]; then
    pushd "$romdir"
    ln -snf "$1" "genesis"
    popd
  fi
}

## @fn moveConfigDir()
## @param from source directory
## @param to destination directory
## @brief Moves the contents of a folder and symlinks to the new location.
function moveConfigDir() {
  local from="$1"
  local to="$2"

  ##If We Are In Remove Mode - Remove The Symlink
  if [[ "$md_mode" == "remove" ]]; then
    [[ -h "$from" ]] && rm -f "$from"
    return
  fi
  mkUserDir "$to"
  ##Move Old Configs to New Location
  if [[ -d "$from" && ! -h "$from" ]]; then
    cp -a "$from/." "$to/"
    rm -rf "$from"
  fi
  ln -snf "$to" "$from"
  ##Set Ownership of Link to $user
  chown -h "$user:$user" "$from"
}

## @fn moveConfigFile()
## @param from source file
## @param to destination file
## @brief Moves the file and symlinks to the new location.
function moveConfigFile() {
  local from="$1"
  local to="$2"

  ##If We Are in Remove Mode, Remove the Symlink
  if [[ "$md_mode" == "remove" && -h "$from" ]]; then
    rm -f "$from"
    return
  fi

  ##Move Old File
  if [[ -f "$from" && ! -h "$from" ]]; then
    mv "$from" "$to"
  fi
  ln -sf "$to" "$from"
  ##Set Ownership Of The Link To $user
  chown -h "$user:$user" "$from"
}

## @fn diffFiles()
## @param file1 file to compare
## @param file2 file to compare
## @brief Compares two files using diff.
## @retval 0 if the files were the same
## @retval 1 if they were not
## @retval >1 an error occurred
function diffFiles() {
  diff -q "$1" "$2" >/dev/null
  return $?
}

## @fn dirIsEmpty()
## @param path path to directory
## @param files_only set to 1 to ignore sub directories
## @retval 0 if the directory is empty
## @retval 1 if the directory is not empty
function dirIsEmpty() {
  if [[ "$2" -eq 1 ]]; then
    [[ -z "$(ls -lA1 "$1" | grep "^-")" ]] && return 0
  else
    [[ -z "$(ls -A "$1")" ]] && return 0
  fi
  return 1
}

## @fn copyDefaultConfig()
## @param from source file
## @param to destination file
## @brief Copies a default configuration.
## @details Copies from the source file to the destination file if the destination
## file doesn't exist. If the destination is the same nothing is done. If different
## the source is copied to `$destination.rgs-dist`.
function copyDefaultConfig() {
  local from="$1"
  local to="$2"
  ##If The Destination Exists And Is Different Then Copy The Config As Name .rgs-dist
  if [[ -f "$to" ]]; then
    if ! diffFiles "$from" "$to"; then
      to+=".rgs-dist"
      printMsgs "console" "Copying new default configuration to $to"
      cp "$from" "$to"
    fi
  else
    printMsgs "console" "Copying default configuration to $to"
    cp "$from" "$to"
  fi
  chown "$user:$user" "$to"
}

## @fn renameModule()
## @param from source file
## @param to destination file
## @brief Renames an existing module.
## @details Renames an existing module, moving it's install folder to the new location
## and changing any references to it in `emulators.cfg`.
function renameModule() {
  local from="$1"
  local to="$2"
  ##Move From Old Location And Update emulators.cfg
  if [[ -d "$rootdir/$md_type/$from" ]]; then
    rm -rf "$rootdir/$md_type/$to"
    mv "$rootdir/$md_type/$from" "$rootdir/$md_type/$to"
    ##Replace Any Default = "$from"
    sed -i --follow-symlinks "s/\"$from\"/\"$to\"/g" "$configdir"/*/emulators.cfg
    ##Replace Any $from = "cmdline"
    sed -i --follow-symlinks "s/^$from\([ =]\)/$to\1/g" "$configdir"/*/emulators.cfg
    ##Replace Any Paths With /$from/
    sed -i --follow-symlinks "s|/$from/|/$to/|g" "$configdir"/*/emulators.cfg
  fi
}

## @fn iniFileEditor()
## @param delim ini file delimiter eg. ' = '
## @param quote ini file quoting character eg. '"'
## @param config ini file to edit
## @brief Allows editing of ini files with a user friendly dialog based gui.
## @details Some arrays need to be configured before calling this, which are
## used to display what can be edited and the options available.
##
## The first array is `$ini_titles` which provides the titles for each
## entry.
##
## The second array is `$ini_descs` which contains a help description for each
## entry.
##
## The third array is `$ini_options` which contains multiple space separated
## strings in each element to control how each entry should be managed.
##
## The `$ini_options` array is constructed as follows:
##
## If the first string is `_function_` then the next string should be a function
## name that will handle that entry. The function will be called with a parameter
## `get` or `set`. The function should return the value for get via `echo`
## and should handle any gui functionality when called with `set`. This can be
## used for example to build custom dialogs.
##
## If the first option is anything else, it is assumed to be a key name, followed
## by a control type and a list of parameters.
##
## Control types are:
##  * `_id_` map the following values to an id
##  * `_string_` allow the value to be inputted by the user
##  * `_file_` select from a list of files. The following values are wildcard, then file path.
##
## If none of the above, then the rest of the array element should be a list of
## possible values for the key.
##
## Some examples for ini_options:
##  ini_options=('video_smooth true false')
## Allow setting of the key `video_smooth` with the values of *true* or *false*
##
##  ini_options=('aspect_ratio_index _id_ 4:3 16:9 16:10)
## Allow setting of the key `aspect_ratio_index` with the values 0 1 or 2 which
## correspond to the ratios. The user is shown the ratios, but the ini configuration
## is set to the id (4:3 = 0, 16:9 = 1, 16:10 = 2).
##
##   ini_options=('_function_ _video_fullscreen_configedit')
## The function `_video_fullscreen_configedit` is called with *get* or *set*
## to manage this entry.
##
##   ini_options=("video_shader _file_ *.*p $rootdir/emulators/retroarch/shader")
## The key `video_shader` will be able to be set to a list of files in
## `$rootdir/emulators/retroarch/shader` that match the wildcard `*.*p`
##
## For more examples you can check out the code in supplementary/configedit.sh
function iniFileEditor() {
  local delim="$1"
  local quote="$2"
  local config="$3"
  [[ ! -f "$config" ]] && return

  iniConfig "$delim" "$quote" "$config"
  local sel
  local value
  local option
  local title
  while true; do
    local options=()
    local params=()
    local values=()
    local keys=()
    local i=0

    ##Generate Menu From Options
    for option in "${ini_options[@]}"; do
      ##Split Into New Array (Globbing Safe)
      read -ra option <<<"$option"
      key="${option[0]}"
      keys+=("$key")
      params+=("${option[*]:1}")

      ##If The First Parameter Is _function_ We Call The Second Parameter As A Function
      ##So We Can Handle Some Options With A Custom Menu
      if [[ "$key" == "_function_" ]]; then
        value="$(${option[1]} get)"
      else
        ##Get Current Value
        iniGet "$key"
        if [[ -n "$ini_value" ]]; then
          value="$ini_value"
        else
          value="unset"
        fi
      fi

      values+=("$value")

      ##Add The Matching Value To Our id IN _id_ Lists
      if [[ "${option[1]}" == "_id_" && "$value" != "unset" ]]; then
        value+=" - ${option[value+2]}"
      fi

      ##Use Custom Title If Provided
      if [[ -n "${ini_titles[i]}" ]]; then
        title="${ini_titles[i]}"
      else
        title="$key"
      fi
      options+=("$i" "$title ($value)" "${ini_descs[i]}")
      ((i++))
    done

    local cmd=(dialog --backtitle "$__backtitle" --default-item "$sel" --item-help --help-button --menu "Please choose the setting to modify in $config" 22 76 16)
    sel=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ "${sel[@]:0:4}" == "HELP" ]]; then
      printMsgs "dialog" "${sel[@]:5}"
      continue
    fi

    [[ -z "$sel" ]] && break

    ##If The Key Is _function_ We Handle The Option With A Custom Function
    if [[ "${keys[sel]}" == "_function_" ]]; then
      "${params[sel]}" set "${values[sel]}"
      continue
    fi

    ##Process The Editing Of The Option
    i=0
    options=("U" "unset")
    local default=""

    ##Split Into New Array (Globbing Safe)
    read -ra params <<<"${params[sel]}"

    local mode="${params[0]}"

    case "$mode" in
    _string_)
      options+=("E" "Edit (Currently ${values[sel]})")
      ;;
    _file_)
      local match="${params[1]}"
      local path="${params[*]:2}"
      local file
      while read -r file; do
        [[ "${values[sel]}" == "$file" ]] && default="$i"
        file="${file//$path\//}"
        options+=("$i" "$file")
        ((i++))
      done < <(find -L "$path" -type f -name "$match" | sort)
      ;;
    _id_ | *)
      [[ "$mode" == "_id_" ]] && params=("${params[@]:1}")
      for option in "${params[@]}"; do
        if [[ "$mode" == "_id_" ]]; then
          [[ "${values[sel]}" == "$i" ]] && default="$i"
        else
          [[ "${values[sel]}" == "$option" ]] && default="$i"
        fi
        options+=("$i" "$option")
        ((i++))
      done
      ;;
    esac
    [[ -z "$default" ]] && default="U"
    ##Display Values
    cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Please choose the value for ${keys[sel]}" 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    ##If It Is A _STRING_ Type We Will Open An Inputbox Dialog To Get A Manual Value
    if [[ -z "$choice" ]]; then
      continue
    elif [[ "$choice" == "E" ]]; then
      [[ "${values[sel]}" == "unset" ]] && values[sel]=""
      cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the value for ${keys[sel]}" 10 60 "${values[sel]}")
      value=$("${cmd[@]}" 2>&1 >/dev/tty)
    elif [[ "$choice" == "U" ]]; then
      value=""
    else
      if [[ "$mode" == "_id_" ]]; then
        value="$choice"
      else
        ##Get The Actual Value From The Options Array
        local index=$((choice * 2 + 3))
        if [[ "$mode" == "_file_" ]]; then
          value="$path/${options[index]}"
        else
          value="${options[index]}"
        fi
      fi
    fi

    if [[ "$choice" == "U" ]]; then
      iniUnset "${keys[sel]}" "$value"
    else
      iniSet "${keys[sel]}" "$value"
    fi
  done
}

## @fn setESSystem()
## @param fullname full name of system
## @param name short name of system
## @param path rom path
## @param extension file extensions to show
## @param command command to run
## @param platform name of platform (used by es for scraping)
## @param theme name of theme to use
## @brief Adds a system entry for Emulation Station (to /etc/emulationstation/es_systems.cfg).
function setESSystem() {
  local function

  for function in $(compgen -A function _add_system_); do
    "$function" "$@"
  done
}

## @fn ensureSystemretroconfig()
## @param system system to create retroarch.cfg for
## @param shader set a default shader to use (deprecated)
## @brief Creates a default retroarch.cfg for specified system in `/opt/archrgs/configs/$system/retroarch.cfg`.
function ensureSystemretroconfig() {
  ##Do Not Do Any Config Work On Module Removal
  [[ "$md_mode" == "remove" ]] && return

  local system="$1"
  local shader="$2"

  if [[ ! -d "$configdir/$system" ]]; then
    mkUserDir "$configdir/$system"
  fi

  local config="$(mktemp)"
  ##Add The Initial Comment Regarding Include Order
  echo -e "# Settings Made Here Will Only Override Settings in the Global retroarch.cfg If Placed Above the #include Line\n" >"$config"

  ##Add The Per System Default Settings
  iniConfig " = " '"' "$config"
  iniSet "input_remapping_directory" "$configdir/$system/"

  if [[ -n "$shader" ]]; then
    iniUnset "video_smooth" "false"
    iniSet "video_shader" "$emudir/rgs-em-retroarch/shader/$shader"
    iniUnset "video_shader_enable" "true"
  fi

  ##Include The Global retroarch config
  echo -e "\n#include \"$configdir/all/retroarch.cfg\"" >>"$config"

  copyDefaultConfig "$config" "$configdir/$system/retroarch.cfg"
  rm "$config"
}

## @fn setRetroArchCoreOption()
## @param option option to set
## @param value value to set
## @brief Sets a retroarch core option in `$configdir/all/retroarch-core-options.cfg`.
function setRetroArchCoreOption() {
  local option="$1"
  local value="$2"
  iniConfig " = " "\"" "$configdir/all/retroarch-core-options.cfg"
  iniGet "$option"
  if [[ -z "$ini_value" ]]; then
    iniSet "$option" "$value"
  fi
  chown "$user:$user" "$configdir/all/retroarch-core-options.cfg"
}

## @fn setConfigRoot()
## @param dir directory under $configdir to use
## @brief Sets module config root `$md_conf_root` to subfolder from `$configdir`
## @details This is used for ports that are not actually in scriptmodules/ports
## as they would get the wrong config root otherwise.
function setConfigRoot() {
  local dir="$1"
  md_conf_root="$configdir"
  [[ -n "$dir" ]] && md_conf_root+="/$dir"
  mkUserDir "$md_conf_root"
}

## @fn loadModuleConfig()
## @param params space separated list of key=value parameters
## @brief Load the settings for a module.
## @details This allows modules to quickly load some settings from an ini file.
## It can provide a shortcut way to load a set of keys from an ini file into
## variables.
##
## It requires iniConfig to be called first to specify the format and file.
##
##  iniConfig " = " '"' "$configdir/all/mymodule.cfg"
##  eval $(loadModuleConfig) 'some_option=1' 'another_option=2'
##
## This would load the keys `some_option` and `another_option` into local
## variables `some_option` and `another_option`. If the keys did not exist
## in mymodule.cfg the variables would be initialised to 1 and 2.
function loadModuleConfig() {
  local options=("$@")
  local option
  local key
  local value

  for option in "${options[@]}"; do
    option=(${option/=/ })
    key="${option[0]}"
    value="${option[@]:1}"
    iniGet "$key"
    if [[ -z "$ini_value" ]]; then
      iniSet "$key" "$value"
      echo "local $key=\"$value\""
    else
      echo "local $key=\"$ini_value\""
    fi
  done
}

## @fn applyPatch()
## @param patch filename of patch to apply
## @brief Apply a patch if it has not already been applied to current folder.
## @details This is used for applying patches against upstream code.
## @retval 0 on success
## @retval 1 on failure
function applyPatch() {
  local patch="$1"
  local patch_applied="${patch##*/}.applied"

  if [[ ! -f "$patch_applied" ]]; then
    if patch -f -p1 <"$patch"; then
      touch "$patch_applied"
      printMsgs "console" "Successfully applied patch: $patch"
    else
      md_ret_errors+=("$md_id patch $patch failed to apply")
      return 1
    fi
  fi
  return 0
}

## @fn runCurl()
## @params ... commandline arguments to pass to curl
## @brief Run curl with chosen parameters and handle curl errors
## @details Runs curl with the provided parameters, whilst also capturing the output and extracting
## any error message, which is stored in the global variable __NET_ERRMSG. Function returns the return
## code provided by curl. The environment variable __curl_opts can be set to override default curl
## parameters, eg - timeouts etc.
## @retval curl return value
function runCurl() {
  local params=("$@")
  ##Add Any User Supplied Curl Opts - Timeouts Can Be Overridden As Curl Uses The Last Parameters Given
  [[ -n "$__curl_opts" ]] && params+=($__curl_opts)

  local cmd_err
  local ret

  ##Get The Last Non Zero Exit Status (Ignoring tee)
  set -o pipefail

  ##Set Up Additional File Descriptor For stdin
  exec 3>&1

  ##Capture stderr - While Passing Both stdout and stderr to Terminal
  ##Curl Like wget Outputs the Progress Meter to stderr, So We Will Extract The Error Line Later
  cmd_err=$(curl "${params[@]}" 2>&1 1>&3 | tee /dev/stderr)
  ret="$?"

  ##Remove stdin Copy
  exec 3>&-

  set +o pipefail

  ##If There Was An Error, Extract It And Put In __NET_ERRMSG
  if [[ "$ret" -ne 0 ]]; then
    ##As We Also Capture The Curl Progress Output, Extract The Last Line Which Contains The Error
    __NET_ERRMSG="${cmd_err##*$'\n'}"
  else
    __NET_ERRMSG=""
  fi
  return "$ret"
}

## @fn download()
## @param url url of file
## @param dest destination name (optional), use - for stdout
## @brief Download a file
## @details Download a file - if the dest parameter is omitted, the file will be downloaded to the current directory.
## If the destination name is a hyphen (-), then the file will be outputted to stdout, for piping to another command
## or retrieving the contents directly to a variable. If the destination is a folder, extract with the basename from
## the url to the destination folder.
## @retval 0 on success
function download() {
  local url="$1"
  local dest="$2"
  local file="${url##*/}"

  ##If No Destination, Get The basename From The URL
  [[ -z "$dest" ]] && dest="${PWD}/$file"

  ##If The Destination Is A Folder, Download To That With Filename From URL
  [[ -d "$dest" ]] && dest="$dest/$file"

  local params=(--location)
  if [[ "$dest" == "-" ]]; then
    params+=(--silent --no-buffer)
  else
    printMsgs "console" "Downloading $url to $dest ..."
    params+=(-o "$dest")
  fi
  params+=(--connect-timeout 10 --speed-limit 1 --speed-time 60 --fail)
  ##Add the URL
  params+=("$url")

  local ret
  runCurl "${params[@]}"
  ret="$?"

  ##If the Download Failed, Remove File, Log Error and Return Error Code
  if [[ "$ret" -ne 0 ]]; then
    ##Remove Dest If Not Set To Stdout And Exists
    [[ "$dest" != "-" && -f "$dest" ]] && rm "$dest"
    md_ret_errors+=("URL $url failed to download.\n\n$__NET_ERRMSG")
  fi
  return "$ret"
}

## @fn downloadAndVerify()
## @param url url of file
## @param dest destination file (optional)
## @brief Download a file and a corresponding .asc signature and verify the contents
## @details Download a file and a corresponding .asc signature and verify the contents.
## The .asc file will be downloaded to verify the file, but will be removed after downloading.
## If the dest parameter is omitted, the file will be downloaded to the current directory
## @retval 0 on success
function downloadAndVerify() {
  local url="$1"
  local dest="$2"
  local file="${url##*/}"

  ##If No Destination, Get The Basename From The URL (Supported By GNU basename)
  [[ -z "$dest" ]] && dest="${PWD}/$file"

  local cmd_out
  local ret=1
  if download "${url}.asc" "${dest}.asc"; then
    if download "$url" "$dest"; then
      cmd_out="$(gpg --verify "${dest}.asc" 2>&1)"
      ret="$?"
        if [[ "$ret" -ne 0 ]]; then
          md_ret_errors+=("$dest failed signature check:\n\n$cmd_out")
        fi
    fi
  fi
  return "$ret"
}

## @fn downloadAndExtract()
## @param url url of archive
## @param dest destination folder for the archive
## @param optional additional parameters to pass to the decompression tool.
## @brief Download and extract an archive
## @details Download and extract an archive.
## @retval 0 on success
function downloadAndExtract() {
  local url="$1"
  local dest="$2"
  shift 2
  local opts=("$@")
  local ext="${url##*.}"
  local file="${url##*/}"
  local temp="$(mktemp -d)"

  ##Download File, Removing Temporary Folder And Returning On Error
  if ! download "$url" "$temp/$file"; then
    rm -rf "$temp"
    return 1
  fi

  mkdir -p "$dest"

  local ret
  case "$ext" in
    exe|zip)
      runCmd unzip "${opts[@]}" -o "$temp/$file" -d "$dest"
    ;;
    *)
      tar -xvf "$temp/$file" -C "$dest" "${opts[@]}"
    ;;
  esac
  ret=$?

  rm -rf "$temp"

  return $ret
}

## @fn joy2keyStart()
## @param left mapping for left
## @param right mapping for right
## @param up mapping for up
## @param down mapping for down
## @param but1 mapping for button 1
## @param but2 mapping for button 2
## @param but3 mapping for button 3
## @param butX mapping for button X ...
## @brief Start joy2key.py process in background to map joystick presses to keyboard
## @details Arguments are curses capability names or hex values starting with '0x'
## see: http://pubs.opengroup.org/onlinepubs/7908799/xcurses/terminfo.html
function joy2keyStart() {
  ##Do Not Start On SSH Sessions (Check For Bracket In Output IP/Name In Brackets Over A SSH Connection)
  [[ "$(who -m)" == *\(* ]] && return

  local params=("$@")
  if [[ "${#params[@]}" -eq 0 ]]; then
    params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b)
  fi

  ##Get The First Joystick Device (If Not Already Set)
  [[ -c "$__joy2key_dev" ]] || __joy2key_dev="/dev/input/jsX"

  ##If No Joystick Device, Or Joy2key Is Already Running Exit
  [[ -z "$__joy2key_dev" ]] || pgrep -f joy2key.py >/dev/null && return 1

  ##If joy2key.py Is Installed Run It With Cursor Keys For Axis/Dpad, And Enter + Space For Buttons 0 And 1
  if "$scriptdir/scriptmodules/supplementary/runcommand/joy2key.py" "$__joy2key_dev" "${params[@]}" 2>/dev/null; then
    __joy2key_pid=$(pgrep -f joy2key.py)
    return 0
  fi
  return 1
}

## @fn joy2keyStop()
## @brief Stop previously started joy2key.py process.
function joy2keyStop() {
  if [[ -n $__joy2key_pid ]]; then
    kill $__joy2key_pid 2>/dev/null
    __joy2key_pid=""
    sleep 1
  fi
}

## @fn getPlatformConfig()
## @param key key to look up
## @brief gets a config from archrgs_platforms.cfg
## @details gets a config from archrgs_platforms.cfg first looking in
## `$configdir/all/archrgs_platforms.cfg` then `$scriptdir/archrgs_platforms.cfg`
## allowing users to override any parts of `$scriptdir/archrgs_platforms.cfg`
function getPlatformConfig() {
  local key="$1"
  local conf
  for conf in "$configdir/all/platforms.cfg" "$scriptdir/platforms.cfg"; do
    [[ ! -f "$conf" ]] && continue
    iniConfig "=" '"' "$conf"
    iniGet "$key"
    [[ -n "$ini_value" ]] && break
  done
  ##Workaround For Arch-RGS Platform
  [[ "$key" == "archrgs_fullname" ]] && ini_value="Arch-RGS"
  echo "$ini_value"
}

## @fn addSystem()
## @param system system to add
## @brief adds an emulator entry / system
## @param fullname optional fullname for the frontend (if not present in archrgs_platforms.cfg)
## @param exts optional extensions for the frontend (if not present in archrgs_platforms.cfg)
## @details Adds a system to one of the frontend launchers
function addSystem() {
  local system="$1"
  local fullname="$2"
  local exts=("$3")

  local platform="$system"
  local theme="$system"
  local cmd
  local path

  ##If Removing And We Don'T Have An emulators.cfg We Can Remove The System From The Frontends
  if [[ "$md_mode" == "remove" ]] && [[ ! -f "$md_conf_root/$system/emulators.cfg" ]]; then
    delSystem "$system" "$fullname"
    return
  fi

  ##Set System/Platform/Theme For Configuration Based On Data In Names Field
  if [[ "$system" == "ports" ]]; then
    cmd="bash %ROM%"
    path="$romdir/ports"
  else
    cmd="$rootdir/supplementary/runcommand/runcommand.sh 0 _SYS_ $system %ROM%"
    path="$romdir/$system"
  fi

  exts+=("$(getPlatformConfig "${system}_exts")")

  local temp
  temp="$(getPlatformConfig "${system}_theme")"
  if [[ -n "$temp" ]]; then
    theme="$temp"
  else
    theme="$system"
  fi

  temp="$(getPlatformConfig "${system}_platform")"
  if [[ -n "$temp" ]]; then
    platform="$temp"
  else
    platform="$system"
  fi

  temp="$(getPlatformConfig "${system}_fullname")"
  [[ -n "$temp" ]] && fullname="$temp"

  exts="${exts[*]}"
  ##Add The Extensions Again As Uppercase
  exts+=" ${exts^^}"

  setESSystem "$fullname" "$system" "$path" "$exts" "$cmd" "$platform" "$theme"
}

## @fn delSystem()
## @param system system to delete
## @brief Deletes a system
## @details deletes a system from all frontends.
function delSystem() {
  local system="$1"
  local fullname="$2"

  local temp
  temp="$(getPlatformConfig "${system}_fullname")"
  [[ -n "$temp" ]] && fullname="$temp"

  local function
  for function in $(compgen -A function _del_system_); do
    "$function" "$fullname" "$system"
  done
}

## @fn addPort()
## @param id id of the module / command
## @param port name of the port
## @param name display name for the launch script
## @param cmd commandline to launch
## @param game rom/game parameter (optional)
## @brief Adds a port to the emulationstation ports menu.
## @details Adds an emulators.cfg entry as with addSystem but also creates a launch script in `$datadir/ports/$name.sh`.
##
## Can also optionally take a game parameter which can be used to create multiple launch
## scripts for different games using the same engine - eg for quake
##
## addPort "rgs-lr-tyrquake" "quake" "Quake" "$emudir/rgs-em-retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so
## --config $md_conf_root/quake/retroarch.cfg %ROM%" "$romdir/ports/quake/id1/pak0.pak"
##
## addPort "rgs-lr-tyrquake" "quake" "Quake Mission Pack 2 (rogue)" "$emudir/rgs-em-retroarch/bin/retroarch 
## -L $md_inst/tyrquake_libretro.so --config $md_conf_root/quake/retroarch.cfg %ROM%" 
## "$romdir/ports/quake/id1/rogue/pak0.pak"
##
## Would add an entry in $configdir/ports/quake/emulators.cfg for rgs-lr-tyrquake (setting it to default if no default set)
## and create a launch script in $romdir/ports for each game.
function addPort() {
  local id="$1"
  local port="$2"
  local file="$romdir/ports/$3.sh"
  local cmd="$4"
  local game="$5"

  ##Move Configurations From Old Ports Location
  if [[ -d "$configdir/$port" ]]; then
    mv "$configdir/$port" "$md_conf_root/"
  fi

  ##Remove The Emulator/Port
  if [[ "$md_mode" == "remove" ]]; then
    delEmulator "$id" "$port"

    ##Remove Launch Script If In Remove Mode And The Ports emulators.cfg Is Empty
    [[ ! -f "$md_conf_root/$port/emulators.cfg" ]] && rm -f "$file"

    ##If There Are No More Port Launch Scripts We Can Remove Ports From Emulation Station
    if [[ "$(find "$romdir/ports" -maxdepth 1 -name "*.sh" | wc -l)" -eq 0 ]]; then
      delSystem "ports"
    fi
    return
  fi

  mkUserDir "$romdir/ports"

  cat >"$file" <<_EOF_
#!/usr/bin/env bash
"$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ "$port" "$game"
_EOF_

  chown "$user:$user" "$file"
  chmod +x "$file"

  [[ -n "$cmd" ]] && addEmulator 1 "$id" "$port" "$cmd"
  addSystem "ports"
}

## @fn addEmulator()
## @param default 1 to make the emulator / command default for the system if no default already set
## @param id unique id of the module / command
## @param name name of the system to add the emulator to
## @param cmd commandline to launch
## @brief Adds a new emulator for a system.
## @details This is the primary function for adding emulators to a system which can be
## switched between via the runcommand launch menu
##
##  addEmulator 1 "vice-x64" "c64" "$md_inst/bin/x64 %ROM%"
##  addEmulator 0 "vice-xvic" "c64" "$md_inst/bin/xvic %ROM%"
##
## Would add two optional emulators for the c64 - with vice-x64 being the default if no default
## was already set. This adds entries to `$configdir/$system/emulators.cfg` with
##
##  id = "cmd"
##  default = id
##
## Which are then selectable from runcommand when launching ROMs
##
## For libretro emulators, cmd needs to only contain the path to the libretro library.
##
## Example for the rgs-lr-fcuemm module:
##
##  addEmulator 1 "$md_id" "nes" "$md_inst/fceumm_libretro.so"
function addEmulator() {
  local default="$1"
  local id="$2"
  local system="$3"
  local cmd="$4"

  ##Check If We Are Removing The System
  if [[ "$md_mode" == "remove" ]]; then
    delEmulator "$id" "$system"
    return
  fi

  ##Automatically Add Parameters For Libretro Modules
  if [[ "$id" == rgs-lr-* && "$cmd" =~ ^"$md_inst"[^[:space:]]*\.so ]]; then
    cmd="$emudir/rgs-em-retroarch/bin/retroarch -L $cmd --config $md_conf_root/$system/retroarch.cfg %ROM%"
  fi

  ##Create A Config Folder For The System Or Port
  mkUserDir "$md_conf_root/$system"

  ##Add The Emulator To The $conf_dir/emulators.cfg If A Commandline Exists (Not Used For Some Ports)
  if [[ -n "$cmd" ]]; then
    iniConfig " = " '"' "$md_conf_root/$system/emulators.cfg"
    iniSet "$id" "$cmd"
    ##Set A Default
    iniGet "default"
    if [[ -z "$ini_value" && "$default" -eq 1 ]]; then
      iniSet "default" "$id"
    fi
    chown "$user:$user" "$md_conf_root/$system/emulators.cfg"
  fi
}

## @fn delEmulator()
## @param id id of emulator to delete
## @param system system to delete from
## @brief Deletes an emulator entry / system
## @details Delete the entry for the id from `$configdir/$system/emulators.cfg`.
## If there are no more emulators for the system present, it will also
## delete the system entry from the installed frontends.
function delEmulator() {
  local id="$1"
  local system="$2"
  local config="$md_conf_root/$system/emulators.cfg"
  ##Remove from Apps List for System
  if [[ -f "$config" && -n "$id" ]]; then
    ##Delete Emulator Entry
    iniConfig " = " '"' "$config"
    iniDel "$id"
    ##If It Is The Default Remove It, Runcommand Will Prompt To Select A New Default
    iniGet "default"
    [[ "$ini_value" == "$id" ]] && iniDel "default"
    ##If We No Longer Have Any Entries In The Emulators.Cfg File We Can Remove It
    grep -q "=" "$config" || rm -f "$config"
  fi

}
## @fn dkmsManager()
## @param mode dkms operation type
## @module_name name of dkms module
## @module_ver version of dkms module
## Helper function to manage DKMS modules installed by Arch-RGS
function dkmsManager() {
  local mode="$1"
  local module_name="$2"
  local module_ver="$3"
  local kernel="$(uname -r)"
  local ver

  case "$mode" in
    install)
      if dkms status | grep -q "^$module_name"; then
        dkmsManager remove "$module_name" "$module_ver"
      fi
      ln -sf "$md_inst" "/usr/src/${module_name}-${module_ver}"
      dkms install --no-initrd --force -m "$module_name" -v "$module_ver" -k "$kernel"
      if ! dkms status "$module_name/$module_ver" -k "$kernel" | grep -q installed; then
        ##Force Building For Any Kernel That Has Source/Headers
        local k_ver
          while read k_ver; do
            if [[ -d "$(realpath /lib/modules/$k_ver/build)" ]]; then
              dkms install --no-initrd --force -m "$module_name/$module_ver" -k "$k_ver"
            fi
          done < <(ls -r1 /lib/modules)
      fi
      if ! dkms status "$module_name/$module_ver" | grep -q installed; then
        md_ret_errors+=("Failed to install $md_id")
        return 1
      fi
    ;;
    remove)
      for ver in $(dkms status "$module_name" | cut -d"," -f2 | cut -d":" -f1); do
        dkms remove -m "$module_name" -v "$ver" --all
        rm -f "/usr/src/${module_name}-${ver}"
      done
      dkmsManager unload "$module_name" "$module_ver"
    ;;
    reload)
      dkmsManager unload "$module_name" "$module_ver"
      ##No Reason To Load Modules In chroot
      if [[ "$__chroot" -eq 0 ]]; then
        modprobe "$module_name"
      fi
    ;;
    unload)
      if [[ -n "$(lsmod | grep ${module_name/-/_})" ]]; then
        rmmod "$module_name"
      fi
    ;;
  esac
}

## @fn getIPAddress()
## @param dev optional specific network device to use for address lookup
## @brief Obtains the current externally routable source IP address of the machine
## @details This function first tries to obtain an external IPv4 route and
## otherwise tries an IPv6 route if the IPv4 route can not be determined.
## If no external route can be determined, nothing will be returned.
## This function uses Google's DNS servers as the external lookup address.
function getIPAddress() {
  local dev="$1"
  local ip_route

  ##Obtain An External IPv4 Route
  ip_route=$(ip -4 route get 8.8.8.8 ${dev:+dev $dev} 2>/dev/null)
  if [[ -z "$ip_route" ]]; then
    ##If No IPv4 Route Obtain An IPv6 Route
    ip_route=$(ip -6 route get 2001:4860:4860::8888 ${dev:+dev $dev} 2>/dev/null)
  fi

  ##If An External Route Was Found, Report Its Source Address
  [[ -n "$ip_route" ]] && grep -oP "src \K[^\s]+" <<<"$ip_route"
}

## @fn isConnected()
## @brief Simple check to see if there is a connection to the Internet.
## @details Uses the getIPAddress function to check if we have a route to the Internet. Also sets
## __NET_ERRMSG with an error message for use in packages / setup to display to the user if not.
## @retval 0 on success
## @retval 1 on failure
function isConnected() {
  local ip="$(getIPAddress)"

  if [[ -z "$ip" ]]; then
    __NET_ERRMSG="Not connected to the Internet"
    return 1
  fi
  return 0
}

## @fn signFile()
## @param file path to file to sign
## @brief signs file with $__gpg_signing_key
## @details signs file with $__gpg_signing_key creating corresponding .asc file in the same folder
function signFile() {
  local file="$1"
  local cmd_out

  cmd_out=$(gpg --default-key "$__gpg_signing_key" --detach-sign --armor --yes "$1" 2>&1)
  if [[ "$?" -ne 0 ]]; then
    md_ret_errors+=("Failed to sign $1\n\n$cmd_out")
    return 1
  fi
  return 0
}


#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

## @file inifuncs.sh
## @brief Arch-RGS inifuncs library
## @copyright GPLv3

# @fn fatalError()
# @param message string or array of messages to display
# @brief echos message, and exits immediately.
function fatalError() {
  echo -e "$1"
  exit 1
}

##ARG 1: DELIMITER, ARG 2: QUOTE, ARG 3: FILE

## @fn iniConfig()
## @param delim ini file delimiter eg. ' = '
## @param quote ini file quoting character eg. '"'
## @param config ini file to edit
## @brief Configure an ini file for getting/setting values with `iniGet` and `iniSet`
function iniConfig() {
  __ini_cfg_delim="$1"
  __ini_cfg_quote="$2"
  __ini_cfg_file="$3"
}

##ARG 1: COMMAND, ARG 2: KEY, ARG 2: VALUE, ARG 3: FILE (OPTIONAL - USES FILE FROM iniConfig IF NOT USED)

# @fn iniProcess()
# @param command `set`, `unset` or `del`
# @param key ini key to operate on
# @param value to set
# @param file optional file to use another file than the one configured with iniConfig
# @brief The main function for setting and deleting from ini files - usually
# not called directly but via iniSet iniUnset and iniDel
function iniProcess() {
  local cmd="$1"
  local key="$2"
  local value="$3"
  local file="$4"
  [[ -z "$file" ]] && file="$__ini_cfg_file"
  local delim="$__ini_cfg_delim"
  local quote="$__ini_cfg_quote"

  [[ -z "$file" ]] && fatalError "No file provided for ini/config change"
  [[ -z "$key" ]] && fatalError "No key provided for ini/config change on $file"

  ##STRIP THE DELIMITER OF SPACES, SO WE MATCH EXISTING ENTRIES THAT HAVE THE WRONG SPACING
  local delim_strip=${delim// /}
  ##IF THE STRIPPED DELIMITER IS EMPTY - SUCH AS IN THE CASE OF A SPACE, JUST USE THE DELIMITER INSTEAD
  [[ -z "$delim_strip" ]] && delim_strip="$delim"
  local match_re="^[[:space:]#]*$key[[:space:]]*$delim_strip.*$"

  local match
  if [[ -f "$file" ]]; then
    match=$(grep -E -i "$match_re" "$file" | tail -1)
  else
    touch "$file"
  fi

  if [[ "$cmd" == "del" ]]; then
    [[ -n "$match" ]] && sed -i --follow-symlinks "\|$(sedQuote "$match")|d" "$file"
    return 0
  fi

  [[ "$cmd" == "unset" ]] && key="# $key"

  local replace="$key$delim$quote$value$quote"
  if [[ -z "$match" ]]; then
    ##MAKE SURE THERE IS A NEWLINE, THEN ADD THE KEY-VALUE PAIR
    sed -i --follow-symlinks '$a\' "$file"
    echo "$replace" >>"$file"
  else
    ##REPLACE EXISTING KEY-VALUE PAIR
    sed -i --follow-symlinks "s|$(sedQuote "$match")|$(sedQuote "$replace")|g" "$file"
  fi

  [[ "$file" =~ retroarch\.cfg$ ]] && retroarchIncludeToEnd "$file"
  return 0
}

## @fn iniUnset()
## @param key ini key to operate on
## @param value to Unset (key will be commented out, but the value can be changed also)
## @param file optional file to use another file than the one configured with iniConfig
## @brief Unset (comment out) a key / value pair in an ini file.
## @details The key does not have to exist - if it doesn't exist a new line will
## be added - eg. `# key = "value"`
##
## This function is useful for creating example configuration entries for users
## to manually enable later or if a configuration is to be disabled but left
## as an example.
function iniUnset() {
  iniProcess "unset" "$1" "$2" "$3"
}

## @fn iniSet()
## @param key ini key to operate on
## @param value to set
## @param file optional file to use another file than the one configured with iniConfig
## @brief Set a key / value pair in an ini file.
## @details If the key already exists the existing line will be changed. If not
## a new line will be created.
function iniSet() {
  iniProcess "set" "$1" "$2" "$3"
}

## @fn iniDel()
## @param key ini key to operate on
## @param file optional file to use another file than the one configured with iniConfig
## @brief Delete a key / value pair in an ini file.
function iniDel() {
  iniProcess "del" "$1" "" "$2"
}

## @fn iniGet()
## @param key ini key to get the value of
## @param file optional file to use another file than the one configured with iniConfig
## @brief Get the value of a key from an ini file.
## @details The value of the key will end up in the global ini_value variable.
function iniGet() {
  local key="$1"
  local file="$2"

  [[ -z "$file" ]] && file="$__ini_cfg_file"
  if [[ ! -f "$file" ]]; then
    ini_value=""
    return 1
  fi

  local delim="$__ini_cfg_delim"
  local quote="$__ini_cfg_quote"
  ##STRIP THE DELIMITER OF SPACES, MATCH EXISTING ENTRIES THAT HAVE THE WRONG SPACING
  local delim_strip=${delim// /}
  ##IF THE STRIPPED DELIMITER IS EMPTY - SUCH AS IN THE CASE OF A SPACE, JUST USE THE DELIMITER INSTEAD
  [[ -z "$delim_strip" ]] && delim_strip="$delim"

  ##CREATE A REGEXP TO MATCH THE VALUE BASED ON WHETHER WE ARE LOOKING FOR QUOTES OR NOT
  local value_m
  if [[ -n "$quote" ]]; then
    value_m="$quote*\([^$quote|\r]*\)$quote*"
  else
    value_m="\([^\r]*\)"
  fi

  ini_value="$(sed -n "s/^[ |\t]*$key[ |\t]*$delim_strip[ |\t]*$value_m.*/\1/p" "$file" | tail -1)"
}

# @fn retroarchIncludeToEnd()
# @param file config file to process
# @brief Makes sure a `retroarch.cfg` file has the `#include` line at the end.
# @details Used in runcommand.sh and iniProcess to ensure the #include for the
# main retroarch.cfg is always at the end of a system `retroarch.cfg`. This
# is because when processing its config RetroArch will take the first value it
# finds, so any overrides need to be above the `#include` line where the global
# retroarch.cfg is included.
function retroarchIncludeToEnd() {
  local config="$1"

  [[ ! -f "$config" ]] && return

  local re="^#include.*retroarch\.cfg"

  ##EXTRACT THE INCLUDE LINE UNLESS IT IS THE LAST LINE IN THE FILE
  ##REMOVE BLANK LINES, THE LAST LINE AND SEARCH FOR AN INCLUDE LINE IN REMAINING LINES
  local include=$(sed '/^$/d;$d' "$config" | grep "$re")

  ##IF MATCHED REMOVE AND READD IT AT THE END
  if [[ -n "$include" ]]; then
    sed -i --follow-symlinks "/$re/d" "$config"
    ##ADD NEWLINE IF MISSING AND THE #include LINE
    sed -i --follow-symlinks '$a\' "$config"
    echo "$include" >>"$config"
  fi
}

##ARG 1: KEY, ARG 2: DEFAULT VALUE (OPTIONAL - IS 1 IF NOT USED)
function addAutoConf() {
  local key="$1"
  local default="$2"
  local file="$configdir/all/autoconf.cfg"

  if [[ -z "$default" ]]; then
    default="1"
  fi

  iniConfig " = " '"' "$file"
  iniGet "$key"
  ini_value="${ini_value// /}"
  if [[ -z "$ini_value" ]]; then
    iniSet "$key" "$default"
    chown $user:$user "$file"
  fi
}

##ARG 1: KEY, ARG 2: VALUE
function setAutoConf() {
  local key="$1"
  local value="$2"
  local file="$configdir/all/autoconf.cfg"

  iniConfig " = " '"' "$file"
  iniSet "$key" "$value"
  chown "$user:$user" "$file"
}

##ARG 1: KEY
function getAutoConf() {
  local key="$1"

  iniConfig " = " '"' "$configdir/all/autoconf.cfg"
  iniGet "$key"

  [[ "$ini_value" == "1" ]] && return 0
  return 1
}

##ESCAPE SPECIAL CHARACTERS FOR sed
function sedQuote() {
  local string="$1"
  string="${string//\\/\\\\}"
  string="${string//|/\\|}"
  string="${string//[/\\[}"
  string="${string//]/\\]}"
  echo "$string"
}

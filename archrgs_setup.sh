#!/usr/bin/env bash

# This file is part of the Arch-RGS project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

scriptdir="$(dirname -- "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

"$scriptdir/archrgs_packages.sh" setup gui


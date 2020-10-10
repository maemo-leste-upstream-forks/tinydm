#!/bin/sh
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

# TODO:
# - complain if file exists and points to valid session
# - different error if session-file from arg does not exist
# - support -f

exit_usage() {
	echo "usage: tinydm-set-default session-file"
	exit 1
}

if ! [ -e "$1" ]; then
	exit_usage
fi

mkdir -p /var/lib/tinydm

target="/var/lib/tinydm/default-session.desktop"
ln -sf "$1" "$target"

echo "tinydm: session set: $1"

#!/bin/sh
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

exit_usage() {
	echo "usage: tinydm-unset-session session-file"
	echo
	echo "Unset a specific session, in case it was set previously."
	exit 1
}

if [ -z "$1" ]; then
	exit_usage
fi

target="/var/lib/tinydm/default-session.desktop"
if ! [ -e "$target" ]; then
	exit 0
fi

resolved="$(realpath "$target")"
if [ "$resolved" = "$1" ]; then
	echo "tinydm: session unset: $1"
	rm "$target"
fi

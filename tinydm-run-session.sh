#!/bin/sh
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

setup_log() {
	exec >~/.tinydm.log 2>&1
}

# $1: file
# $2: key
parse_xdg_desktop() {
	grep "^$2=" "$1" | cut -d "=" -f 2-
}

# $1: Exec line from .desktop file
run_session_wayland() {
	export XDG_SESSION_TYPE=wayland
	exec $1
}

# $1: Exec line from .desktop file
run_session_x() {
	export XDG_SESSION_TYPE=X11
	exec startx $1
}

run_session() {
	target="/var/lib/tinydm/default-session.desktop"

	if ! [ -e "$target" ]; then
		echo "ERROR: no session configured!"
		exit 1
	fi

	resolved="$(realpath "$target")"
	cmd="$(parse_xdg_desktop "$resolved" "Exec")"

	echo "--- tinydm ---"
	echo "Date:    $(date)"
	echo "Session: $resolved"
	echo "Exec:    $cmd"
	echo "---"

	case "$resolved" in
		/usr/share/wayland-sessions*)
			run_session_wayland "$cmd"
			;;
		/usr/share/x-sessions*)
			run_session_x "$cmd"
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

setup_log
run_session

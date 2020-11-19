#!/bin/sh
# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

setup_log() {
	logfile=${XDG_CACHE_DIR:-~/.cache}/tinydm.log
	mkdir -p "$(dirname "$logfile")"
	exec >"$logfile" 2>&1
}

# $1: file
# $2: key
parse_xdg_desktop() {
	grep "^$2=" "$1" | cut -d "=" -f 2-
}

# $1: Exec line from .desktop file
run_session_wayland() {
	export XDG_SESSION_TYPE=wayland
	exec "$@"
}

# $1: Exec line from .desktop file
run_session_x() {
	export XDG_SESSION_TYPE=X11
	exec "$@"
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
			# shellcheck disable=SC2086
			run_session_wayland $cmd
			;;
		/usr/share/xsessions*)
			# shellcheck disable=SC2086
			run_session_x $cmd
			;;
		*)
			echo "ERROR: could not detect session type!"
			exit 1
			;;
	esac
}

setup_log
run_session

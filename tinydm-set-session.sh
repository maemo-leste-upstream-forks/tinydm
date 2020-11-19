#!/bin/sh
# Copyright 2020 Oliver Smith
# Copyright 2020 Clayton Craft
# SPDX-License-Identifier: GPL-3.0-or-later
exit_usage() {
	echo "usage: $0 [-f] -s session-file"
	exit 1
}
force=false
while getopts fs:h opt; do
        case "$opt" in
                f) force=true ;;
                s) session=$OPTARG ;;
                h|?) exit_usage ;;
        esac
done

[ -z "$session" ] && exit_usage

if ! [ -e "$session" ]; then
	echo "tinydm: Session file does not exist: $session"
        exit 1
fi

mkdir -p /var/lib/tinydm

target="/var/lib/tinydm/default-session.desktop"
session_old=$(readlink -f $target)
if [ -e "$session_old" ] && ! $force; then
	echo "tinydm: Session already set to: $session_old"
        echo "tinydm: To change it, run: 'tinydm-set-session -f -s $session'"
        exit 0
fi

ln -sf "$session" "$target"

echo "tinydm: session set: $session"

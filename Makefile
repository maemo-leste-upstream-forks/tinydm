# Copyright 2020 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

DESTDIR :=
OPENRC	:= 1

install:
	install -Dm755 tinydm-run-session.sh \
		"$(DESTDIR)/usr/bin/tinydm-run-session"
	install -Dm755 tinydm-set-session.sh \
		"$(DESTDIR)/usr/bin/tinydm-set-session"
	install -Dm755 tinydm-unset-session.sh \
		"$(DESTDIR)/usr/bin/tinydm-unset-session"

	if [ "$(OPENRC)" = "1" ]; then \
		install -Dm755 tinydm.initd \
			"$(DESTDIR)/etc/init.d/tinydm"; \
		install -Dm644 tinydm.confd \
			"$(DESTDIR)/etc/conf.d/tinydm"; \
	fi

#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY
"""Pass build-time Wi-Fi defaults without interpolating credentials into shell."""

import json
import os
from pathlib import Path
import re
import sys
import tempfile


def uci_string(value):
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def write_atomic(path, content, mode):
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=path.parent,
                                     prefix=path.name + '.', delete=False) as file:
        temporary = Path(file.name)
        try:
            os.fchmod(file.fileno(), mode)
            file.write(content)
            file.flush()
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def configure(root, ssid, password):
    if not 1 <= len(ssid.encode('utf-8')) <= 32 or any(ord(c) < 32 or ord(c) == 127 for c in ssid):
        raise ValueError('WRT_SSID must contain 1 to 32 UTF-8 bytes without control characters')
    if not 8 <= len(password) <= 63 or any(not 32 <= ord(c) <= 126 for c in password):
        raise ValueError('WRT_WORD must contain 8 to 63 printable ASCII characters')

    router = root / 'package/emortal/luci-app-router-tool'
    config = router / 'root/etc/config/router-tool'
    selection = []
    if (root / '.config').is_file():
        selection = re.findall(r'(?m)^(?:CONFIG_PACKAGE_luci-app-router-tool=([ymn])|(# CONFIG_PACKAGE_luci-app-router-tool is not set))$',
                               (root / '.config').read_text(encoding='utf-8'))
    enabled = not selection or selection[-1][0] == 'y'
    if router.is_dir() and enabled:
        if not config.is_file():
            raise ValueError('Router Tool lacks the wireless defaults interface; update the firmware source')
        source = config.read_text(encoding='utf-8')
        section = re.compile(r"(?m)^config[ \t]+wireless[ \t]+['\"]?defaults['\"]?[ \t]*\n(?:(?!config\b).*(?:\n|$))*")
        block = ("config wireless 'defaults'\n"
                 f'\toption ssid_prefix {uci_string(ssid)}\n'
                 f'\toption key {uci_string(password)}\n\n')
        updated, count = section.subn(lambda match: block, source)
        if count != 1:
            raise ValueError('Router Tool lacks the wireless defaults interface; update the firmware source')
        write_atomic(config, updated, 0o600)
        return ssid + '-<Vendor>-<Band>'

    generator = root / 'package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc'
    if not generator.is_file():
        return 'No wifi-scripts generator in this source'
    source = generator.read_text(encoding='utf-8')
    for option, value in [('ssid', ssid), ('key', password)]:
        pattern = re.compile(r'(?m)^(set \$\{si\}\.' + option + r'=).*$')
        # JSON quotes also protect the UCI batch value, including quotes and
        # backslashes. Credentials are never interpreted by Bash or sed.
        expression = "${sprintf('%J', " + json.dumps(value, ensure_ascii=False) + ')}'
        source, count = pattern.subn(lambda match: match[1] + expression, source)
        if count != 1:
            raise ValueError('Unsupported wifi-scripts layout for ' + option + '; no files changed')
    write_atomic(generator, source, generator.stat().st_mode & 0o777)
    return ssid


def main():
    try:
        description = configure(Path.cwd(), os.environ.get('WRT_SSID', 'OWRT'),
                                os.environ.get('WRT_WORD', '12345678'))
    except (OSError, ValueError) as error:
        print('Wi-Fi defaults: ' + str(error), file=sys.stderr)
        return 1
    if os.environ.get('GITHUB_ENV'):
        with Path(os.environ['GITHUB_ENV']).open('a', encoding='utf-8') as env:
            env.write('WRT_WIFI_NAME_INFO=' + description + '\n')
    print('Wi-Fi defaults configured (' + description + '); password omitted from logs')
    return 0


if __name__ == '__main__':
    sys.exit(main())

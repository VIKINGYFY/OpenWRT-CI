import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('configure_wifi', ROOT / 'Scripts/configure-wifi.py')
wifi = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(wifi)


class WifiDefaultsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.config = self.root / 'package/emortal/luci-app-router-tool/root/etc/config/router-tool'
        self.generator = self.root / 'package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc'

    def write(self, path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding='utf-8')

    def test_router_tool_preserves_settings_and_generator(self):
        source = "config settings 'main'\n\toption keep 'yes'\n\nconfig wireless 'defaults'\n"
        self.write(self.config, source)
        self.write(self.generator, 'generator must remain unchanged\n')
        wifi.configure(self.root, 'Home', 'DifferentPassword')
        saved = self.config.read_text()
        self.assertIn("option keep 'yes'", saved)
        self.assertIn('option ssid_prefix "Home"', saved)
        self.assertIn('option key "DifferentPassword"', saved)
        self.assertEqual(self.generator.read_text(), 'generator must remain unchanged\n')
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o600)
        wifi.configure(self.root, 'Home', 'DifferentPassword')
        self.assertEqual(self.config.read_text(), saved)

    def test_credentials_are_quoted_as_data(self):
        self.write(self.config, "config settings 'main'\n\nconfig wireless 'defaults'\n")
        ssid = '家WiFi\'"&/\\${value}'
        password = 'test\'"&/\\`$(id)${value}'
        wifi.configure(self.root, ssid, password)
        saved = self.config.read_text()
        self.assertIn('option ssid_prefix ' + wifi.uci_string(ssid), saved)
        self.assertIn('option key ' + wifi.uci_string(password), saved)

    def test_invalid_input_leaves_files_unchanged(self):
        source = "config settings 'main'\n\nconfig wireless 'defaults'\n"
        self.write(self.config, source)
        for ssid, password in [('', '12345678'), ('家' * 11, '12345678'),
                               ('bad\nname', '12345678'), ('home', 'short'),
                               ('home', 'x' * 64), ('home', 'password\n'),
                               ('home', 'password\u00e9')]:
            with self.subTest(ssid=ssid, password_length=len(password)):
                with self.assertRaises(ValueError):
                    wifi.configure(self.root, ssid, password)
                self.assertEqual(self.config.read_text(), source)

    def test_old_router_tool_fails_instead_of_skipping_initialization(self):
        source = "config settings 'main'\n"
        self.write(self.config, source)
        with self.assertRaisesRegex(ValueError, 'update the firmware source'):
            wifi.configure(self.root, 'Home', '12345678')
        self.assertEqual(self.config.read_text(), source)

    def test_old_router_tool_without_own_config_fails(self):
        (self.root / 'package/emortal/luci-app-router-tool').mkdir(parents=True)
        with self.assertRaisesRegex(ValueError, 'update the firmware source'):
            wifi.configure(self.root, 'Home', '12345678')

    def test_disabled_or_modular_router_tool_uses_generator(self):
        source = "config settings 'main'\n"
        self.write(self.config, source)
        for flag in ['CONFIG_PACKAGE_luci-app-router-tool=n',
                     'CONFIG_PACKAGE_luci-app-router-tool=m',
                     '# CONFIG_PACKAGE_luci-app-router-tool is not set']:
            with self.subTest(flag=flag):
                self.write(self.root / '.config', 'CONFIG_PACKAGE_luci-app-router-tool=y\n' + flag + '\n')
                self.write(self.generator, "set ${si}.ssid='old'\nset ${si}.key='old'\n")
                description = wifi.configure(self.root, 'Home', '12345678')
                self.assertEqual(description, 'Home')
                self.assertEqual(self.config.read_text(), source)
                self.assertIn('sprintf', self.generator.read_text())

    def test_official_generator_uses_quoted_uci_batch_values(self):
        self.write(self.generator, "print(`set ${si}=wifi-iface\nset ${si}.ssid='${defaults?.ssid || 'ImmortalWrt'}'\nset ${si}.key='${defaults?.key || ''}'\n`);\n")
        wifi.configure(self.root, 'Home', '12345678')
        saved = self.generator.read_text()
        self.assertIn('set ${si}.ssid=${sprintf(\'%J\', "Home")}', saved)
        self.assertIn('set ${si}.key=${sprintf(\'%J\', "12345678")}', saved)
        wifi.configure(self.root, 'Home', '12345678')
        self.assertEqual(self.generator.read_text(), saved)

    def test_unknown_generator_fails_without_partial_write(self):
        source = "set ${si}.ssid='old'\nunknown password layout\n"
        self.write(self.generator, source)
        with self.assertRaisesRegex(ValueError, 'Unsupported wifi-scripts layout'):
            wifi.configure(self.root, 'Home', '12345678')
        self.assertEqual(self.generator.read_text(), source)

    def test_source_without_wireless_is_supported(self):
        self.assertIn('No wifi-scripts', wifi.configure(self.root, 'Home', '12345678'))

    def test_settings_selects_path_after_manual_package_override(self):
        self.write(self.config, "config settings 'main'\n\nconfig wireless 'defaults'\n")
        self.write(self.generator, "set ${si}.ssid='old'\nset ${si}.key='old'\n")
        self.write(self.root / '.config', 'CONFIG_PACKAGE_luci-app-router-tool=y\n')
        self.write(self.root / 'package/base-files/files/bin/config_generate', "hostname='old'\n")
        for path in ['feeds/luci/collections', 'feeds/luci/modules/luci-mod-system',
                     'feeds/luci/modules/luci-mod-status']:
            (self.root / path).mkdir(parents=True)
        env = dict(os.environ, GITHUB_WORKSPACE=str(ROOT), GITHUB_ENV=str(self.root / 'env'),
                   WRT_SSID='Home', WRT_WORD='12345678', WRT_THEME='bootstrap',
                   WRT_IP='192.168.10.1', WRT_NAME='OWRT', WRT_MARK='CI', WRT_DATE='test',
                   WRT_TARGET='x86', WRT_WIFI='none', WRT_PACKAGE='CONFIG_PACKAGE_luci-app-router-tool=n')
        subprocess.run(['bash', '-e', str(ROOT / 'Scripts/Settings.sh')], cwd=self.root,
                       env=env, check=True, capture_output=True)
        self.assertIn('sprintf', self.generator.read_text())
        self.assertNotIn('ssid_prefix', self.config.read_text())
        self.assertIn('WRT_WIFI_NAME_INFO=Home\n', (self.root / 'env').read_text())


if __name__ == '__main__':
    unittest.main()

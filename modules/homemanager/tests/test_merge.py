import importlib.util
import json
from pathlib import Path
import tempfile
import sys
import unittest

SOURCE = Path(__file__).resolve().parents[1] / "tachi"
sys.path.insert(0, str(SOURCE))
spec = importlib.util.spec_from_file_location("merge", SOURCE / "merge.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class MergeTests(unittest.TestCase):
    def test_jsonc_preserves_customizations_comments_and_trailing_commas(self):
        old = '''{
  // retain this explanation
  "custom": {"url": "http://example.test/,}", "items": [1, 2,],},
  "git.autofetch": false, /* retain this comment */
}'''
        settings = {"git.autofetch": True, "new": ["a", "b"]}
        new = m.patch_jsonc(old, settings)
        self.assertIn('// retain this explanation', new)
        self.assertIn('/* retain this comment */', new)
        self.assertIn('"custom": {"url": "http://example.test/,}", "items": [1, 2,],}', new)
        self.assertIn('"git.autofetch": true', new)
        self.assertEqual(m.patch_jsonc(new, settings), new)

    def test_jsonc_rejects_non_objects_and_malformed_files(self):
        for text in ['[]', '{"secret":', '{bad: 1}', ' /* unterminated']:
            with self.subTest(text=text), self.assertRaises((ValueError, json.JSONDecodeError)):
                m.patch_jsonc(text, {"a": 1})

    def test_jsonc_bom_and_boolean_types(self):
        text = '\ufeff{"git.autofetch": 1}'
        new = m.patch_jsonc(text, {"git.autofetch": True})
        self.assertTrue(new.startswith('\ufeff'))
        self.assertIn('"git.autofetch": true', new)

    def test_ini_retains_other_sections_and_comments(self):
        old = '# note\n[Preferences]\nKeep=sentinel\n[BitTorrent]\nSession\\QueueingSystemEnabled=true\n'
        new = m.patch_ini(old, {"BitTorrent": {"Session\\QueueingSystemEnabled": "false"}})
        self.assertIn('# note\n[Preferences]\nKeep=sentinel', new)
        self.assertIn('Session\\QueueingSystemEnabled=false', new)
        self.assertEqual(m.patch_ini(new, {"BitTorrent": {"Session\\QueueingSystemEnabled": "false"}}), new)

    def test_xml_changes_only_keymap_component(self):
        old = '<application><component name="Custom"><option value="sentinel" /></component><component name="KeymapManager"><active_keymap name="VSCode" /></component></application>'
        new = m.keymap_xml(old, 'Visual Studio')
        self.assertIn('name="Custom"', new)
        self.assertIn('value="sentinel"', new)
        self.assertIn('name="Visual Studio"', new)
        self.assertEqual(m.keymap_xml(new, 'Visual Studio'), new)

    def test_vlc_commented_section_header(self):
        old = '[qt] # Qt interface\nqt-privacy-ask=0\ncustom=keep\n'
        self.assertEqual(m.patch_ini(old, {'qt': {'qt-privacy-ask': '0'}}), old)
        new = m.patch_ini(old, {'qt': {'qt-privacy-ask': '1'}})
        self.assertEqual(new.count('[qt]'), 1)
        self.assertIn('custom=keep', new)
        self.assertIn('qt-privacy-ask=1', new)

    def test_plan_rejects_symlinks_before_writing(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            outside = home / 'elsewhere'
            outside.write_text('untouched')
            (home / 'bad').symlink_to(outside)
            policy = {"operations": [{"kind": "ini", "path": "bad", "values": {"": {"a": "b"}}}]}
            with self.assertRaises(ValueError):
                m.build_plan(home, policy)
            self.assertEqual(outside.read_text(), 'untouched')

    def test_autostart_symlinks_do_not_block_repeat_activation(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            autostart = home / '.config/autostart'
            autostart.mkdir(parents=True)
            outside = home / 'unmanaged-launcher.desktop'
            outside.write_text('[Desktop Entry]\\nExec=steam %U\\n')
            link = autostart / 'plasma-manager-autostart.desktop'
            link.symlink_to(outside)
            (autostart / 'old-steam.desktop').write_text('[Desktop Entry]\\nExec=steam %U\\n')
            policy = {'operations': [], 'jetbrains': {}, 'wallpaper': str(SOURCE / 'assets')}
            writes = m.build_plan(home, policy)
            self.assertNotIn('.config/autostart/plasma-manager-autostart.desktop', writes)
            self.assertIn('Hidden=true', writes['.config/autostart/old-steam.desktop'].decode())
            self.assertTrue(link.is_symlink())
            self.assertNotIn('Hidden=', outside.read_text())

    def test_apply_backup_artwork_and_unmanaged_files(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            def put(path, contents):
                f = home / path
                f.parent.mkdir(parents=True, exist_ok=True)
                f.write_bytes(contents)
            put('.zshrc', b'export KEEP=1\nfastfetch\nfastfetch --logo custom\n')
            put('.config/obs-studio/user.ini', b'OBS remains unmanaged')
            put('toggle-screen.sh', b'protected monitor script')
            put('.config/autostart/old-steam.desktop', b'[Desktop Entry]\nExec=steam %U\n')
            put('.config/autostart/old-discord.desktop', b'[Desktop Entry]\nExec=/nix/store/example/opt/Discord/.Discord-wrapped\n')
            put('.config/autostart/unrelated.desktop', b'[Desktop Entry]\nExec=dolphin /home/tachi/steam\n')
            original = (SOURCE / 'assets/index.html').read_bytes()
            put('bckg/index.html', original)
            policy = {"operations": [], "jetbrains": {}, "wallpaper": str(SOURCE / 'assets'), "backupPaths": []}
            plan = m.build_plan(home, policy)
            self.assertEqual((home / 'bckg/index.html').read_bytes(), original)
            m.apply_plan(home, policy, plan)
            self.assertEqual((home / 'bckg/index.html').read_bytes(), original.replace(m.REMOTE_SUNCALC, b'suncalc.js'))
            self.assertEqual((home / '.zshrc').read_text(), 'export KEEP=1\nfastfetch --logo custom\n')
            self.assertEqual((home / '.config/obs-studio/user.ini').read_bytes(), b'OBS remains unmanaged')
            self.assertEqual((home / 'toggle-screen.sh').read_bytes(), b'protected monitor script')
            for name in ['Background-Day.png', 'Background-Night.png', 'Mikleo.png', 'Sorey.png']:
                self.assertEqual((home / 'bckg' / name).read_bytes(), (SOURCE / 'assets' / name).read_bytes())
            for name in ['old-steam', 'old-discord']:
                self.assertIn('Hidden=true', (home / f'.config/autostart/{name}.desktop').read_text())
            self.assertNotIn('Hidden=', (home / '.config/autostart/unrelated.desktop').read_text())
            backups = list((home / '.local/state/nixconfig-home/backups').iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / 'bckg/index.html').read_bytes(), original)
            self.assertEqual(m.build_plan(home, policy), {})

    def test_explicit_rollback_preview_and_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / 'existing').write_bytes(b'original')
            (home / 'existing').chmod(0o640)
            writes = {'existing': b'new', 'created': b'new file'}
            backup = m.apply_plan(home, {}, writes, apply=False)
            m.apply_plan(home, {}, writes)
            m.restore_backup(home, backup)
            self.assertEqual((home / 'existing').read_bytes(), b'new')
            self.assertTrue((home / 'created').exists())
            m.restore_backup(home, backup, apply=True)
            self.assertEqual((home / 'existing').read_bytes(), b'original')
            self.assertEqual((home / 'existing').stat().st_mode & 0o777, 0o640)
            self.assertFalse((home / 'created').exists())

    def test_rollback_rejects_unsafe_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            backup = home / 'backup'; backup.mkdir()
            (backup / 'manifest.json').write_text(json.dumps({'../outside': {'exists': False, 'link': None}}))
            with self.assertRaises(ValueError):
                m.restore_backup(home, backup, apply=True)


if __name__ == '__main__':
    unittest.main()

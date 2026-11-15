"""Cleanup only fresh fixtures; never invoke the real clean CLI or scan /tmp."""
from contextlib import redirect_stdout, redirect_stderr
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / 'tachi'
sys.path.insert(0, str(SOURCE))
import maintenance as m
ACTIVE_DIRECTORY = m.active_legacy_directory


class MaintenanceTests(unittest.TestCase):
    def setUp(self):
        self.sandbox = tempfile.TemporaryDirectory(prefix='nixconfig-clean-test-')
        self.addCleanup(self.sandbox.cleanup)
        self.root = Path(self.sandbox.name)
        self.home = self.root / 'home'
        self.home.mkdir()
        self.tmp = self.root / 'tmp'
        self.tmp.mkdir()
        self.state = m.state_directory(self.home)
        self.output = io.StringIO()
        self.errors = io.StringIO()
        # Process discovery has its own fixture tests; never inspect live /proc
        # as part of deleting these newly created fixtures.
        activity = patch.object(m, 'active_legacy_directory', return_value=False)
        activity.start()
        self.addCleanup(activity.stop)

    def put(self, relative, content='sentinel'):
        path = self.home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def clean(self):
        with m.operation_lock(self.home), redirect_stdout(self.output), redirect_stderr(self.errors):
            return m.cleanup(self.home, temporary_root=self.tmp)

    def legacy_kwin(self, name='hm-kwin-validation-known'):
        path = self.tmp / name
        path.mkdir()
        (path / 'window.qml').write_text('import QtQuick\nimport QtQuick.Window\nWindow { visible: true; width: 600; height: 400; title: "Isolated snap validation" }\n')
        (path / 'observe0.js').write_text('const w = workspace.activeWindow; console.log("HM_TEST_GEOMETRY_0=" + JSON.stringify(w ? {x:w.frameGeometry.x,y:w.frameGeometry.y,width:w.frameGeometry.width,height:w.frameGeometry.height,output:w.output.name} : null));')
        (path / 'run.sh').write_text('kwin_wayland --virtual --no-lockscreen --no-kactivities --output-count 2')
        return path

    def test_all_backups_removed_preserving_live_files_and_other_home(self):
        for name in ['automatic', 'pre-activation', 'pre-rollback', 'incomplete']:
            self.put(str(m.STATE / 'backups' / name / '.config/app'), 'backup')
        sentinels = [self.put(path) for path in [
            '.config/app', 'Documents/work', 'bckg/index.html', 'bckg/Sorey.png',
            '.ssh/key', '.local/state/other-app/backups/keep', '.config/.nixconfig-unregistered']]
        other = self.root / 'other-host-home'
        other.mkdir()
        (other / 'backup').write_text('other user/host')
        unrelated = self.tmp / 'hm-unrelated.txt'
        unrelated.write_text('keep')
        self.assertEqual(self.clean(), 0)
        self.assertFalse((self.state / 'backups').exists())
        self.assertTrue(all(path.read_text() == 'sentinel' for path in sentinels))
        self.assertEqual((other / 'backup').read_text(), 'other user/host')
        self.assertEqual(unrelated.read_text(), 'keep')
        self.assertIn('Removed', self.output.getvalue())

    def test_missing_and_repeated_cleanup_keep_same_lock_inode(self):
        self.assertEqual(self.clean(), 0)
        inode = (self.state / 'operation.lock').stat().st_ino
        self.assertEqual(self.clean(), 0)
        self.assertEqual((self.state / 'operation.lock').stat().st_ino, inode)
        self.assertIn('No migration backups', self.output.getvalue())

    def test_marked_validation_only(self):
        owned = self.state / 'validation/owned'
        owned.mkdir(parents=True)
        (owned / m.MARKER).write_text(json.dumps(m.PROVENANCE))
        (owned / 'fixture.conf').write_text('generated fixture')
        unknown = self.state / 'validation/unrelated'
        unknown.mkdir()
        (unknown / 'keep').write_text('keep')
        self.assertEqual(self.clean(), 0)
        self.assertFalse(owned.exists())
        self.assertEqual((unknown / 'keep').read_text(), 'keep')
        self.assertIn('Preserved unrecognized', self.output.getvalue())

    def test_legacy_signatures_not_prefix_alone(self):
        recognized = self.legacy_kwin()
        unknown = self.tmp / 'hm-kwin-validation-unrelated'
        unknown.mkdir()
        (unknown / 'keep').write_text('not a test')
        self.assertEqual(self.clean(), 0)
        self.assertFalse(recognized.exists())
        self.assertEqual((unknown / 'keep').read_text(), 'not a test')

    def test_active_legacy_test_preserved_and_reported(self):
        recognized = self.legacy_kwin()
        with patch.object(m, 'active_legacy_directory', return_value=True):
            self.assertEqual(self.clean(), 1)
        self.assertTrue(recognized.exists())
        self.assertIn('active legacy test', self.errors.getvalue())

    def test_process_discovery_uses_exact_sandbox_and_virtual_command(self):
        proc = self.root / 'proc/999999999'
        proc.mkdir(parents=True)
        target = self.tmp / 'hm-kwin-validation-example'
        (proc / 'cmdline').write_bytes(b'/usr/bin/kwin_wayland\0--virtual\0')
        (proc / 'environ').write_bytes(b'ROOT=' + os.fsencode(target) + b'\0')
        self.assertTrue(ACTIVE_DIRECTORY(target, proc.parent))
        (proc / 'environ').write_bytes(b'ROOT=/another/test\0')
        self.assertFalse(ACTIVE_DIRECTORY(target, proc.parent))
        (proc / 'cmdline').write_bytes(b'python3\0' + os.fsencode(target / 'input.json') + b'\0')
        self.assertTrue(ACTIVE_DIRECTORY(target, proc.parent))

    def test_unreadable_environment_only_blocks_relevant_writer(self):
        proc = self.root / 'proc/999999999'
        proc.mkdir(parents=True)
        (proc / 'environ').mkdir()  # Reading this fails, as restricted /proc can.
        (proc / 'cmdline').write_bytes(b'/usr/bin/systemd\0--user\0')
        self.assertFalse(ACTIVE_DIRECTORY(self.tmp, proc.parent))
        (proc / 'cmdline').write_bytes(b'/usr/bin/kwin_wayland\0--virtual\0')
        self.assertTrue(ACTIVE_DIRECTORY(self.tmp, proc.parent))

    def test_symlinked_backup_root_and_parent_refused(self):
        outside = self.root / 'outside'
        outside.mkdir()
        (outside / 'keep').write_text('keep')
        (self.state / 'backups').symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'symlink'):
            self.clean()
        self.assertEqual((outside / 'keep').read_text(), 'keep')

    def test_backup_symlink_does_not_follow_target(self):
        outside = self.put('Documents/keep')
        backups = self.state / 'backups'
        backups.mkdir()
        (backups / 'link').symlink_to(outside)
        self.assertEqual(self.clean(), 0)
        self.assertEqual(outside.read_text(), 'sentinel')

    def test_redirected_parent_and_foreign_home_refused(self):
        other_home = self.root / 'redirected-home'
        other_home.mkdir()
        (other_home / '.local').symlink_to(self.home / '.local', target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'symlink'):
            with m.operation_lock(other_home):
                self.fail('Followed redirected state directory')
        current_uid = os.getuid()
        with patch.object(m.os, 'getuid', return_value=current_uid + 1000):
            with self.assertRaisesRegex(ValueError, 'not owned'):
                self.clean()

    def test_mounted_entries_and_removal_errors_reported(self):
        self.put(str(m.STATE / 'backups' / 'one'), 'backup')
        with patch.object(m.shutil, 'rmtree', side_effect=PermissionError('fixture refusal')) as remove:
            remove.avoids_symlink_attacks = True
            self.assertEqual(self.clean(), 1)
        self.assertIn('fixture refusal', self.errors.getvalue())
        self.assertTrue((self.state / 'backups/one').exists())
        with patch.object(m.os.path, 'ismount', side_effect=lambda p: Path(p) == self.state / 'backups'):
            self.assertEqual(self.clean(), 1)
        self.assertTrue((self.state / 'backups/one').exists())

    def test_staging_journal_requires_exact_inode(self):
        stage = self.put('.config/.nixconfig-test', 'unfinished')
        registry = self.state / 'staging'
        registry.mkdir()
        info = stage.stat()
        record = registry / 'one.json'
        record.write_text(json.dumps({'path': '.config/.nixconfig-test', 'device': info.st_dev, 'inode': info.st_ino + 1}))
        self.assertEqual(self.clean(), 1)
        self.assertTrue(stage.exists())
        self.assertTrue(record.exists())
        record.write_text(json.dumps({'path': '.config/.nixconfig-test', 'device': info.st_dev, 'inode': info.st_ino}))
        self.assertEqual(self.clean(), 0)
        self.assertFalse(stage.exists())
        self.assertFalse(record.exists())
        self.assertEqual(self.clean(), 0)

    def test_staging_and_rollback_temporary_files_are_registered(self):
        target = self.put('.config/app', 'original')
        with m.staging_file(self.home, target.parent, '.nixconfig-restore-') as (stream, path):
            stream.write(b'new')
            stream.flush()
            self.assertEqual(len(list((self.state / 'staging').iterdir())), 1)
            os.replace(path, target)
        self.assertEqual(target.read_text(), 'new')
        self.assertEqual(list((self.state / 'staging').iterdir()), [])
        self.assertEqual(list(target.parent.glob('.nixconfig-*')), [])

    def test_migration_backup_check_and_rollback_are_blocked_by_lock(self):
        policy = self.root / 'policy.json'
        policy.write_text(json.dumps({'operations': [], 'wallpaper': str(SOURCE / 'assets')}))
        for mode in [['--apply'], ['--backup'], ['--check'], ['--restore', str(self.root / 'missing')]]:
            with self.subTest(mode=mode), m.operation_lock(self.home):
                result = subprocess.run([sys.executable, str(SOURCE / 'merge.py'), '--home', str(self.home),
                                         '--policy', str(policy), *mode], capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('is active', result.stderr)
                self.assertFalse((self.state / 'backups').exists())

    def test_inherited_activation_lock_stays_held(self):
        policy = self.root / 'policy.json'
        policy.write_text(json.dumps({'operations': [], 'wallpaper': str(SOURCE / 'assets')}))
        with m.operation_lock(self.home) as fd:
            result = subprocess.run([sys.executable, str(SOURCE / 'merge.py'), '--home', str(self.home),
                                     '--policy', str(policy), '--check', '--lock-fd', str(fd)],
                                    pass_fds=(fd,), capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            with self.assertRaisesRegex(RuntimeError, 'is active'):
                with m.operation_lock(self.home):
                    self.fail('Unexpected second lock')
        self.assertEqual(self.clean(), 0)

    def test_validation_registration_holds_lock_and_reuses_it(self):
        program = ('from maintenance import validation_directory; '
                   'print(validation_directory("test-"), flush=True); '
                   'print(validation_directory("second-"), flush=True); input()')
        env = dict(os.environ, HOME=str(self.home), PYTHONPATH=str(SOURCE))
        process = subprocess.Popen([sys.executable, '-c', program], env=env, stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            first = Path(process.stdout.readline().strip())
            second = Path(process.stdout.readline().strip())
            self.assertEqual(first.parent, self.state / 'validation')
            self.assertTrue((first / m.MARKER).exists())
            self.assertTrue(second.exists())
            with self.assertRaisesRegex(RuntimeError, 'is active'):
                self.clean()
            output, errors = process.communicate('\n', timeout=5)
            self.assertEqual(process.returncode, 0, errors)
        finally:
            if process.poll() is None:
                process.kill()
                process.communicate()
        self.assertEqual(self.clean(), 0)
        self.assertFalse(first.exists())
        self.assertFalse(second.exists())

    def test_bash_activation_fd_is_inherited_and_keeps_lock(self):
        policy = self.root / 'policy.json'
        policy.write_text(json.dumps({'operations': [], 'wallpaper': str(SOURCE / 'assets')}))
        lock = self.state / 'operation.lock'
        script = '''set -eu
exec {migration_fd}>"$1"
flock -n "$migration_fd"
"$2" "$3" --home "$4" --policy "$5" --check --lock-fd "$migration_fd"
if "$2" "$3" --home "$4" --policy "$5" --check; then exit 9; fi
'''
        result = subprocess.run(['bash', '-c', script, '--', str(lock), sys.executable,
                                 str(SOURCE / 'merge.py'), str(self.home), str(policy)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('is active', result.stderr)
        self.assertEqual(self.clean(), 0)

    def test_nh_failure_skips_user_cleanup_and_preserves_status(self):
        with patch.object(sys, 'argv', ['maintenance', '--home', str(self.home), '--system-clean']), \
             patch.object(m.subprocess, 'run', return_value=subprocess.CompletedProcess([], 73)), \
             patch.object(m, 'cleanup') as cleanup, redirect_stderr(self.errors):
            self.assertEqual(m.main(), 73)
            cleanup.assert_not_called()
        self.assertIn('nh clean all failed', self.errors.getvalue())

    def test_system_and_user_cleanup_hold_the_same_lock(self):
        def assert_locked(*args, **kwargs):
            with self.assertRaisesRegex(RuntimeError, 'is active'):
                with m.operation_lock(self.home):
                    self.fail('Unlocked')
            return subprocess.CompletedProcess([], 0)
        def user_cleanup(home):
            self.assertEqual(home, self.home)
            assert_locked()
            return 1
        with patch.object(sys, 'argv', ['maintenance', '--home', str(self.home), '--system-clean']), \
             patch.object(m.subprocess, 'run', side_effect=assert_locked), \
             patch.object(m, 'cleanup', side_effect=user_cleanup), redirect_stdout(self.output):
            self.assertEqual(m.main(), 1)

    def test_nh_signal_exit_matches_shell_status(self):
        with patch.object(sys, 'argv', ['maintenance', '--home', str(self.home), '--system-clean']), \
             patch.object(m.subprocess, 'run', return_value=subprocess.CompletedProcess([], -15)), \
             patch.object(m, 'cleanup') as cleanup, redirect_stderr(self.errors):
            self.assertEqual(m.main(), 143)
            cleanup.assert_not_called()


if __name__ == '__main__':
    unittest.main()

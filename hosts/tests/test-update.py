#!/usr/bin/env python3
"""Exercise update.sh in a temporary home with inert nh/sudo executables."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[2] / "update.sh"


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="nixupdate-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.script = self.root / "update.sh"
        shutil.copy2(SCRIPT, self.script)
        # Never call the real maintenance CLI: /tmp may contain real artifacts.
        helper = self.root / "modules/homemanager/tachi/maintenance.py"
        helper.parent.mkdir(parents=True)
        helper.write_text('import os, subprocess, sys\nassert sys.argv[1:] == ["--home", os.environ["HOME"], "--system-clean"]\nprint("Mock Home Manager maintenance")\nstatus = subprocess.run(["nh", "clean", "all"]).returncode\nsys.exit(status or int(os.environ.get("UPDATE_TEST_HOME_CLEAN_EXIT", "0")))\n')
        self.config = self.root / ".lightswitch.conf"
        self.config.write_text('MAX_JOBS=2\nCORES=4\nGITHUB_TOKEN=""\n')
        self.log = self.root / "calls.jsonl"
        binaries = self.root / "bin"
        binaries.mkdir()
        mock = '''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
with open(os.environ["UPDATE_TEST_LOG"], "a") as f:
    f.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "nh":
    sys.exit(int(os.environ.get("UPDATE_TEST_NH_EXIT", "0")))
'''
        for name in ("nh", "sudo"):
            binary = binaries / name
            binary.write_text(mock)
            binary.chmod(0o755)
        self.env = dict(os.environ)
        self.env.update(
            PATH=str(binaries) + os.pathsep + os.environ["PATH"],
            HOME=str(self.root / "home"),
            UPDATE_TEST_LOG=str(self.log),
            UPDATE_TEST_NH_EXIT="0",
        )

    def run_update(self, args=(), *, code=0, input_text=None, script=None):
        if self.log.exists():
            self.log.unlink()
        result = subprocess.run(
            ["bash", str(script or self.script), *args], env=self.env,
            text=True, input=input_text, capture_output=True,
        )
        self.assertEqual(result.returncode, code, result.stderr + result.stdout)
        self.last_result = result
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        self.assertEqual(calls[-1], ["sudo", "-k"])
        return calls

    def test_actions_and_power_precedence(self):
        cases = [
            ([], "switch", None), (["update"], "switch", None),
            (["boot"], "boot", None), (["switch"], "switch", None),
            (["reboot"], "boot", ["sudo", "reboot"]),
            (["--reboot"], "boot", ["sudo", "reboot"]),
            (["--shutdown"], "boot", ["sudo", "systemctl", "poweroff"]),
            (["--sleep"], "switch", ["sudo", "systemctl", "suspend"]),
            (["switch", "--reboot"], "switch", ["sudo", "reboot"]),
            (["--reboot", "switch"], "switch", ["sudo", "reboot"]),
            (["boot", "--sleep"], "boot", ["sudo", "systemctl", "suspend"]),
            (["--shutdown", "--sleep"], "switch", ["sudo", "systemctl", "suspend"]),
        ]
        for args, action, power in cases:
            with self.subTest(args=args):
                calls = self.run_update(args)
                expected = ["nh", "os", action, "--update", "--",
                            "--option", "max-jobs", "2", "--option", "cores", "4"]
                self.assertIn(expected, calls)
                self.assertEqual(calls, [["sudo", "-v"], expected]
                                 + ([power] if power else []) + [["sudo", "-k"]])

    def test_cli_and_config_overrides(self):
        self.config.write_text('MAX_JOBS=3\nCORES=5\nGITHUB_TOKEN="test-placeholder"\n')
        for flags in ([], ["-j", "1", "-c", "2"],
                      ["--jobs", "1", "--cores", "2"]):
            with self.subTest(flags=flags):
                calls = self.run_update(["update", *flags])
                jobs, cores = ("1", "2") if flags else ("3", "5")
                self.assertIn(["nh", "os", "switch", "--update", "--",
                               "--option", "max-jobs", jobs, "--option", "cores", cores,
                               "--option", "access-tokens", "github.com=test-placeholder"], calls)

    def test_invalid_arguments(self):
        for args in (["-j"], ["-c"], ["--jobs", "0"], ["--cores", "-1"],
                     ["-j", "x"], ["update", "--unknown"], ["unknown"]):
            with self.subTest(args=args):
                self.assertEqual(self.run_update(args, code=1), [["sudo", "-k"]])

    def test_clean_and_all(self):
        calls = self.run_update(["clean"])
        self.assertEqual(calls, [["sudo", "-v"], ["nh", "clean", "all"], ["sudo", "-k"]])
        self.assertIn("Mock Home Manager maintenance", self.last_result.stdout)
        calls = self.run_update(["all", "boot", "-j", "1", "-c", "2"])
        self.assertEqual([c[:3] for c in calls if c[0] == "nh"],
                         [["nh", "clean", "all"], ["nh", "os", "boot"]])

    def test_failure_stops_power_actions_and_all(self):
        self.env["UPDATE_TEST_NH_EXIT"] = "73"
        for args in (["--reboot"], ["--shutdown"], ["--sleep"], ["all"]):
            with self.subTest(args=args):
                calls = self.run_update(args, code=73)
                self.assertEqual([c for c in calls if c[0] == "sudo"],
                                 [["sudo", "-v"], ["sudo", "-k"]])
                if args == ["all"]:
                    self.assertFalse(any(c[:2] == ["nh", "os"] for c in calls))

    def test_home_cleanup_failure_stops_all_before_update_and_power(self):
        self.env["UPDATE_TEST_HOME_CLEAN_EXIT"] = "19"
        calls = self.run_update(["all", "--sleep"], code=19)
        self.assertEqual(calls, [["sudo", "-v"], ["nh", "clean", "all"], ["sudo", "-k"]])

    def test_setup_and_symlink(self):
        self.config.unlink()
        calls = self.run_update(["setup"], input_text="\n\n\n")
        self.assertFalse(any(c[0] == "nh" for c in calls))
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o600)
        link = Path(self.env["HOME"]) / ".local/bin/nixupdate"
        self.assertEqual(link.resolve(), self.script)
        calls = self.run_update(script=link)
        self.assertIn(["nh", "os", "switch"], [c[:3] for c in calls])

    def test_automatic_setup(self):
        self.config.unlink()
        calls = self.run_update(input_text="\n\n\n")
        self.assertIn(["nh", "os", "switch"], [c[:3] for c in calls])

    def test_help(self):
        self.assertEqual(self.run_update(["--help"]), [["sudo", "-k"]])


if __name__ == "__main__":
    unittest.main()

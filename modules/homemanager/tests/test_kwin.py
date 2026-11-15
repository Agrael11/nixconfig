"""Real snap actions in private D-Bus/KWin; never loads the live home/session."""
import argparse
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--qml', type=Path, required=True)
parser.add_argument('--direction', choices=['left', 'right'], default='right')
args = parser.parse_args()
root = Path(tempfile.mkdtemp(prefix='hm-kwin-validation-'))
for name in ['home', 'runtime', 'config', 'data', 'cache', 'state']:
    (root / name).mkdir(mode=0o700)
env = dict(os.environ)
for name in ['DBUS_SESSION_BUS_ADDRESS', 'DISPLAY', 'WAYLAND_DISPLAY', 'QT_QPA_PLATFORM', 'XDG_SESSION_ID']:
    env.pop(name, None)
env.update(
    HOME=str(root/'home'), XDG_RUNTIME_DIR=str(root/'runtime'),
    XDG_CONFIG_HOME=str(root/'config'), XDG_DATA_HOME=str(root/'data'),
    XDG_CACHE_HOME=str(root/'cache'), XDG_STATE_HOME=str(root/'state'),
    DBUS_SYSTEM_BUS_ADDRESS='unix:path=' + str(root/'no-system-bus'),
    WAYLAND_DISPLAY='phase12-test', LIBGL_ALWAYS_SOFTWARE='1',
    QT_QUICK_BACKEND='software', QT_FORCE_STDERR_LOGGING='1',
    QT_LOGGING_TO_CONSOLE='1', QT_LOGGING_RULES='kwin_scripting.debug=true;js.debug=true',
    ROOT=str(root), QML=str(args.qml), ACTION='Tachi Snap ' + args.direction.title(),
)
source = Path(__file__).resolve().parents[1] / 'tachi/snap-cycle.js'
(root/'snap.js').write_text(source.read_text())
(root/'window.qml').write_text('import QtQuick\nimport QtQuick.Window\nWindow { visible: true; width: 600; height: 400; title: "Isolated snap validation" }\n')
for index in range(6):
    (root/f'observe{index}.js').write_text(
        'const w = workspace.activeWindow; console.log("HM_TEST_GEOMETRY_' + str(index)
        + '=" + JSON.stringify(w ? {x:w.frameGeometry.x,y:w.frameGeometry.y,'
        + 'width:w.frameGeometry.width,height:w.frameGeometry.height,output:w.output.name} : null));')
runner = root/'run.sh'
runner.write_text('''#!/usr/bin/env bash
set -eu
kwin_wayland --virtual --no-lockscreen --no-kactivities --output-count 2 --width 1920 --height 1080 --socket phase12-test > "$ROOT/kwin.log" 2>&1 &
kwin_pid=$!
app_pid=''
trap 'if [ -n "$app_pid" ]; then kill "$app_pid" 2>/dev/null || true; fi; kill "$kwin_pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 15); do
  if qdbus org.kde.KWin /Scripting >/dev/null 2>&1; then break; fi
  sleep 1
done
"$QML" -platform wayland "$ROOT/window.qml" > "$ROOT/app.log" 2>&1 &
app_pid=$!
sleep 3
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$ROOT/snap.js" phase12-snap
qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start
for n in 0 1 2 3 4 5; do
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$ROOT/observe$n.js" "phase12-observe$n"
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start
  sleep 0.3
  if [ "$n" -lt 5 ]; then
    qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut "$ACTION"
    sleep 0.7
  fi
done
''')
print('Isolated test artifacts:', root, flush=True)
process = subprocess.Popen(['dbus-run-session', '--', 'bash', str(runner)],
                           env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, start_new_session=True)
try:
    output, _ = process.communicate(timeout=45)
finally:
    if process.poll() is None:
        os.killpg(process.pid, signal.SIGTERM)
(root/'driver.log').write_text(output)
if process.returncode:
    raise RuntimeError(f'Compositor test failed; see {root}')
log = (root/'kwin.log').read_text()
rows = [json.loads(row) for row in re.findall(r'HM_TEST_GEOMETRY_\d+=(\{.*\})', log)]
assert len(rows) == 6, f'Missing observations: {root}'
original = rows[0]
if args.direction == 'right':
    assert rows[1]['x'] == 960 and rows[3]['x'] == 1920 and rows[5]['x'] == 2880, rows
else:
    assert rows[1]['x'] == 0 and rows[3]['x'] == 2880 and rows[5]['x'] == 1920, rows
assert rows[1]['width'] == 960 and rows[3]['width'] == 960, rows
assert rows[2] == original, rows
assert rows[3]['output'] != original['output'], rows
assert rows[4]['x'] == original['x'] + 1920 and rows[4]['width'] == original['width'], rows
print('PASS:', args.direction, 'registered action -> half -> restore -> other output -> restore -> half')

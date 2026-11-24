"""Test emitted layout scripts in private Plasma/KWin, never the live session.

Pass the manifest and one host's programs.plasma.startup.desktopScript JSON.
Hardware sensors, provider responses and visual appearance need host testing.
"""
import argparse
import configparser
import re
import json
import os
import pathlib
import subprocess
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tachi"))
from maintenance import validation_directory
import signal
parser = argparse.ArgumentParser()
parser.add_argument('manifest', type=pathlib.Path)
parser.add_argument('scripts', type=pathlib.Path)
parser.add_argument('--host', choices=['Desktop', 'Laptop'], default='Desktop')
args = parser.parse_args()
source = pathlib.Path(__file__).resolve().parents[1] / 'tachi'
outputs = 2 if args.host == 'Desktop' else 1
r=validation_directory('plasma-')
for n in ['home','runtime','config','data','cache','state']: (r/n).mkdir(mode=0o700)
env=dict(os.environ)
for n in ['DBUS_SESSION_BUS_ADDRESS','DISPLAY','WAYLAND_DISPLAY','QT_QPA_PLATFORM','XDG_SESSION_ID']: env.pop(n,None)
g=json.loads(args.manifest.read_text())[args.host]['generation']
env.update(HOME=str(r/'home'),XDG_RUNTIME_DIR=str(r/'runtime'),XDG_CONFIG_HOME=str(r/'config'),XDG_DATA_HOME=str(r/'data'),XDG_CACHE_HOME=str(r/'cache'),XDG_STATE_HOME=str(r/'state'),DBUS_SYSTEM_BUS_ADDRESS='unix:path='+str(r/'no-system-bus'),WAYLAND_DISPLAY='phase12-test',LIBGL_ALWAYS_SOFTWARE='1',QT_QUICK_BACKEND='software',QT_FORCE_STDERR_LOGGING='1',QT_LOGGING_TO_CONSOLE='1',ROOT=str(r),OUTPUTS=str(outputs),XDG_DATA_DIRS=g+'/home-path/share:'+env.get('XDG_DATA_DIRS','/run/current-system/sw/share'),QTWEBENGINE_DISABLE_SANDBOX='1')
s=json.loads(args.scripts.read_text())
for k,v in s.items(): (r/(k+'.js')).write_text(v['text'].replace('/home/tachi',str(r/'home')))
(r/'weather.js').write_text((source / 'tray-weather.js').read_text()+'\nprint("TACHI_WEATHER_UPDATED:" + configureTrayWeather('+json.dumps(json.loads((source / 'layout-data.json').read_text())['trayWeather'])+'));')
(r/'observe.js').write_text('''print(JSON.stringify({panels:panels().map(p=>({id:p.id,screen:p.screen,height:p.height,hiding:p.hiding,lengthMode:p.lengthMode,widgets:p.widgets().map(w=>w.type)})),desktops:desktops().map(d=>({id:d.id,screen:d.screen,widgets:d.widgets().map(w=>w.type)}))}));''')
(r/'run.sh').write_text('''set -eu
kwin_wayland --virtual --no-lockscreen --no-kactivities --output-count "$OUTPUTS" --width 1920 --height 1080 --socket phase12-test > "$ROOT/kwin.log" 2>&1 &
k=$!
p=''
trap 'if [ -n "$p" ]; then kill "$p" 2>/dev/null || true; fi; kill "$k" 2>/dev/null || true' EXIT
for attempt in $(seq 1 15); do
 if qdbus org.kde.KWin /Scripting >/dev/null 2>&1; then break; fi
 sleep 1
done
plasmashell --no-respawn > "$ROOT/plasma.log" 2>&1 &
p=$!
for attempt in $(seq 1 20); do
 if qdbus org.kde.plasmashell /PlasmaShell >/dev/null 2>&1; then break; fi
 sleep 1
done
sleep 3
for script in panels set_desktop_widgets; do
 qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$ROOT/$script.js")"
done
sleep 5
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$ROOT/weather.js")"
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$ROOT/observe.js")"
''')
print('Isolated artifacts:',r,flush=True)
with (r/'driver.log').open('w') as log:
 p=subprocess.Popen(['dbus-run-session','--','bash',str(r/'run.sh')],env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
 try: p.wait(timeout=50)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGTERM);p.wait(timeout=5)
assert p.returncode == 0, f'Session failed; inspect {r}'
log = (r/'driver.log').read_text()
rows = [json.loads(line) for line in log.splitlines() if line.startswith('{"panels":')]
assert len(rows) == 1, f'Missing layout observation; inspect {r}'
result = rows[0]
assert sorted(p['screen'] for p in result['panels']) == list(range(outputs)), result
expected = ['org.kde.plasma.' + name for name in [
    'kickoff', 'advanced-weather-widget', 'icontasks', 'pager',
    'marginsseparator', 'systemtray', 'digitalclock', 'showdesktop']]
for panel in result['panels']:
    assert panel['height'] == 54 and panel['hiding'] == 'dodgewindows', panel
    assert panel['lengthMode'] == 'fit' and panel['widgets'] == expected, panel
for desktop in result['desktops']:
    assert len(desktop['widgets']) == (8 if desktop['screen'] == outputs - 1 else 0), desktop
assert f'TACHI_WEATHER_UPDATED:{outputs}' in log, f'Tray discovery failed; inspect {r}'
config = (r/'config/plasma-org.kde.plasma.desktop-appletsrc').read_text()
assert config.count('placeDisplayName=Banská Bystrica, Slovakia, SK') == outputs
assert config.count('provider=bbcukmet') == outputs
ini = configparser.RawConfigParser(strict=False)
ini.optionxform = str
ini.read_string(config)
desktop = next(d for d in result['desktops'] if d['screen'] == outputs - 1)
group = 'Containments][' + str(desktop['id'])
geometry = {}
for entry in ini.get(group, 'ItemGeometries-1920x1080').split(';'):
    match = re.fullmatch(r'Applet-(\d+):([^;]+)', entry)
    if match:
        geometry[match[1]] = [float(n) for n in match[2].split(',')[:4]]
for widget in json.loads((source/'layout-data.json').read_text())['widgets']:
    title = widget['config'].get('Appearance', {}).get('title')
    candidates = []
    for section in ini.sections():
        match = re.fullmatch(re.escape(group) + r'\]\[Applets\]\[(\d+)', section)
        if not match or ini.get(section, 'plugin', fallback='') != widget['name']:
            continue
        if title and ini.get(section + '][Configuration][Appearance', 'title', fallback='') != title:
            continue
        candidates.append(match[1])
    assert len(candidates) == 1, (widget['role'], candidates)
    actual = geometry[candidates[0]]
    expected_geometry = [widget['position']['horizontal'], widget['position']['vertical'],
                         widget['size']['width'], widget['size']['height']]
    assert all(abs(a-b) < 1 for a,b in zip(actual, expected_geometry)), (widget['role'], actual)
print('PASS:', args.host, 'panel screens/order/height/hiding, all eight widget coordinates/sizes and actual tray weather writes')

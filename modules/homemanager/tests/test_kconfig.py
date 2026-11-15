"""Exercise the resolved Plasma Manager writer in temporary config directories."""
import argparse
import pathlib
import tempfile
import json
import subprocess
parser = argparse.ArgumentParser()
parser.add_argument('manifest', type=pathlib.Path)
parser.add_argument('writer', type=pathlib.Path)
args = parser.parse_args()
manifest=json.load(args.manifest.open())
for host,data in manifest.items():
 root=pathlib.Path(tempfile.mkdtemp(prefix='hm-kconfig-'+host+'-'))
 kde=root/'kdeglobals';kde.write_text('[KDE]\nUserCustom=keep-me\n')
 (root/'powerdevilrc').write_text('[BatteryManagement]\nBatteryCriticalLevel=7\nBatteryLowLevel=13\n[Battery][Display]\nDimDisplayWhenIdle=true\n')
 config={str(root/name):value for name,value in data['kconfig'].items()}
 path=root/'input.json';path.write_text(json.dumps(config))
 subprocess.run(['python3',str(args.writer),str(path),'',''],check=True,capture_output=True,text=True)
 assert 'UserCustom=keep-me' in kde.read_text()
 assert (root/'konsolerc').read_text().startswith('MenuBar=Disabled')
 power=(root/'powerdevilrc').read_text()
 assert '[Battery][SuspendAndShutdown]' in power and 'AutoSuspendIdleTimeoutSec=900' in power and 'AutoSuspendAction=1' in power
 assert 'BatteryCriticalAction=1' in power
 assert 'BatteryCriticalLevel=7' in power and 'BatteryLowLevel=13' in power
 assert 'TurnOffDisplayWhenIdle=false' in power
 lock=(root/'kscreenlockerrc').read_text()
 assert 'Autolock=false' in lock
 assert ('LockOnResume=true' if host=='Laptop' else 'LockOnResume=false') in lock
 shortcuts=(root/'kglobalshortcutsrc').read_text()
 assert 'Window Maximize=Meta+Up' in shortcuts and 'Tachi Snap Right=Meta+Right' in shortcuts
 assert 'CurrentMonitorScreenShot=Print' in shortcuts
 assert not (root/'obs-studio').exists()
 print(host,'actual Plasma Manager writer: root Konsole key, power enums/timers, locking, shortcuts and preservation: PASS',root)

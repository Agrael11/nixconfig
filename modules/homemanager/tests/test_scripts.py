"""Run the actual scripts against small API fixtures; no live D-Bus/session."""
from pathlib import Path
import subprocess
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tachi"))
from maintenance import validation_directory

source = Path(__file__).resolve().parents[1] / "tachi"
harness = r'''
function assert(ok, message) { if (!ok) throw new Error(message); }
const callbacks = {};
function registerShortcut(name, text, keys, callback) { callbacks[name] = callback; }
const KWin = {MaximizeArea: 0};
const a = {geometry: {x: 0, y: 0, width: 1920, height: 1080}};
const b = {geometry: {x: 1920, y: 0, width: 1920, height: 1080}};
const workspace = {
  screens: [a, b], currentDesktop: {}, activeWindow: null,
  clientArea(kind, output) { return output.geometry; },
  sendClientToScreen(w, output) { w.output = output; }
};
function windowAt(output) {
  return { normalWindow: true, resizeable: true, moveable: true, fullScreen: false,
    output, frameGeometry: {x: output.geometry.x + 100, y: 100, width: 600, height: 400},
    setMaximize() {} };
}
'''
tests = r'''
let w = windowAt(a); workspace.activeWindow = w;
callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 960 && w.frameGeometry.width === 960, 'right half');
callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 100 && w.frameGeometry.width === 600, 'restore before crossing');
callbacks['Tachi Snap Right']();
assert(w.output === b && w.frameGeometry.x === 1920, 'next output left half');
callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 2020 && w.frameGeometry.width === 600, 'restore on next output');
callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 2880, 'right half on next output');
w = windowAt(a); workspace.activeWindow = w;
callbacks['Tachi Snap Left'](); callbacks['Tachi Snap Left'](); callbacks['Tachi Snap Left']();
assert(w.output === b && w.frameGeometry.x === 2880, 'left mirrors and wraps outputs');
workspace.screens = [a]; w = windowAt(a); workspace.activeWindow = w;
for (let i = 0; i < 8; i++) callbacks['Tachi Snap Right']();
assert(w.output === a && w.frameGeometry.x === 100, 'single output half/restore cycle');
w = windowAt(a); workspace.activeWindow = w; callbacks['Tachi Snap Left']();
w.frameGeometry.x = 200; w.frameGeometry.width = 700;
callbacks['Tachi Snap Right'](); callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 200 && w.frameGeometry.width === 700, 'manual resize resets saved state');
w = windowAt(a); w.fullScreen = true; workspace.activeWindow = w; callbacks['Tachi Snap Right']();
assert(w.frameGeometry.x === 100, 'fullscreen window left alone');
workspace.activeWindow = null; callbacks['Tachi Snap Right']();
print('Snap cycling fixture: PASS');
'''
tray_harness = r'''
const tree = {children: {Containments: {children: {
  randomPanel: {children: {Applets: {children: {
    randomTray: {children: {Applets: {children: {
      arbitraryWeather: {entries: {plugin: 'org.kde.plasma.weather'}}
    }}}}
  }}}},
  unrelated: {entries: {plugin: 'org.kde.plasma.digitalclock'}}
}}}};
function ConfigFile(parent, name) {
  this.node = typeof parent === 'string' ? tree.children[name] :
    ((parent.node.children || (parent.node.children = {}))[name] ||
      (parent.node.children[name] = {}));
}
Object.defineProperty(ConfigFile.prototype, 'groupList', {get() {return Object.keys(this.node.children || {});}});
ConfigFile.prototype.readEntry = function(key) {return (this.node.entries || {})[key] || '';};
ConfigFile.prototype.writeEntry = function(key, value) {(this.node.entries || (this.node.entries = {}))[key] = value;};
'''
tray_tests = r'''
const settings = {WeatherStation: {placeDisplayName: 'Banská Bystrica, Slovakia, SK', provider: 'bbcukmet'}};
assert(configureTrayWeather(settings) === 1, 'weather found with arbitrary IDs');
const target = tree.children.Containments.children.randomPanel.children.Applets.children.randomTray.children.Applets.children.arbitraryWeather;
assert(target.children.Configuration.children.WeatherStation.entries.provider === 'bbcukmet', 'nested weather configured');
assert(!tree.children.Containments.children.unrelated.children, 'unrelated widget untouched');
print('Tray weather fixture: PASS');
'''
directory = validation_directory("js-")
script = Path(directory) / "test.js"
script.write_text(harness + (source / "snap-cycle.js").read_text() + tests
                 + tray_harness + (source / "tray-weather.js").read_text() + tray_tests)
subprocess.run([sys.argv[1], str(script)], check=True)

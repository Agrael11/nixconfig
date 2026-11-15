// KWin 6.6 scripting API. No shell commands, output mode changes or fixed IDs.
// Repeated Right: right half -> restore -> next output's left half -> restore
// -> right half. Left mirrors this. One output cycles half/restore only.
"use strict";
const states = new WeakMap();
function rectCopy(r) { return {x: r.x, y: r.y, width: r.width, height: r.height}; }
function near(a, b) {
    return ["x", "y", "width", "height"].every(k => Math.abs(a[k] - b[k]) < 3);
}
function area(output) {
    return workspace.clientArea(KWin.MaximizeArea, output, workspace.currentDesktop);
}
function put(w, r) {
    w.setMaximize(false, false);
    // KWin's script converter accepts a plain geometry object. Mutating the
    // QVariant value returned by frameGeometry does not update its gadget.
    w.frameGeometry = rectCopy(r);
    return rectCopy(r);
}
function restore(w, s) {
    const a = area(w.output);
    const width = Math.min(s.original.width, a.width);
    const height = Math.min(s.original.height, a.height);
    const target = put(w, {x: a.x + Math.max(0, Math.min(s.dx, a.width - width)),
            y: a.y + Math.max(0, Math.min(s.dy, a.height - height)), width, height});
    if (s.maximizeMode) w.setMaximize(Boolean(s.maximizeMode & 1), Boolean(s.maximizeMode & 2));
    return target;
}
function tile(w, direction, output) {
    const a = area(output || w.output);
    const width = Math.floor(a.width / 2);
    return put(w, {x: a.x + (direction > 0 ? width : 0), y: a.y,
            width: direction > 0 ? a.width - width : width, height: a.height});
}
function cycle(direction) {
    const w = workspace.activeWindow;
    if (!w || !w.normalWindow || !w.resizeable || !w.moveable || w.fullScreen) return;
    const outputs = workspace.screens.slice().sort((a, b) => a.geometry.x - b.geometry.x || a.geometry.y - b.geometry.y);
    let s = states.get(w);
    if (!s || !near(w.frameGeometry, s.last) || outputs.indexOf(w.output) < 0) {
        const a = area(w.output);
        s = { original: rectCopy(w.frameGeometry), dx: w.frameGeometry.x - a.x,
              dy: w.frameGeometry.y - a.y, maximizeMode: w.maximizeMode || 0,
              stage: "normal", direction };
    }
    if (s.direction !== direction) {
        s.last = restore(w, s);
        s.stage = "normal";
        s.direction = direction;
    } else if (s.stage === "near" || s.stage === "far") {
        s.last = restore(w, s);
        s.stage = s.stage === "near" ? "restored-near" : "restored-far";
    } else if (s.stage === "restored-near" && outputs.length > 1) {
        const index = outputs.indexOf(w.output);
        const output = outputs[(index + direction + outputs.length) % outputs.length];
        workspace.sendClientToScreen(w, output);
        s.last = tile(w, -direction, output);
        s.stage = "far";
    } else {
        s.last = tile(w, direction);
        s.stage = "near";
    }
    // Wayland clients acknowledge configure asynchronously: compare against the
    // requested target at the next keypress, not the pre-ack frame geometry.
    states.set(w, s);
}
registerShortcut("Tachi Snap Left", "Cycle half-screen snap left", "Meta+Left", () => cycle(-1));
registerShortcut("Tachi Snap Right", "Cycle half-screen snap right", "Meta+Right", () => cycle(1));

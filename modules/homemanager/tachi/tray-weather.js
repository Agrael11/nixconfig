// Plasma 6 ConfigFile shares plasmashell's live Corona configuration. Discover
// nested applets by plugin name; never assume containment or applet IDs.
function configureTrayWeather(settings) {
    var count = 0;
    function visit(group, depth) {
        if (depth > 20) return;
        if (group.readEntry("plugin") === "org.kde.plasma.weather") {
            var configuration = new ConfigFile(group, "Configuration");
            Object.keys(settings).forEach(function(section) {
                var target = configuration;
                section.split("/").forEach(function(name) { target = new ConfigFile(target, name); });
                Object.keys(settings[section]).forEach(function(key) {
                    target.writeEntry(key, settings[section][key]);
                });
            });
            count++;
        }
        var names = group.groupList;
        for (var i = 0; i < names.length; i++) visit(new ConfigFile(group, names[i]), depth + 1);
    }
    // An empty KConfig group is the default group, not the root group tree.
    visit(new ConfigFile("plasma-org.kde.plasma.desktop-appletsrc", "Containments"), 0);
    return count;
}

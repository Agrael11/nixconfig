{ config, pkgs, lib, ... }:

let
	addLegacy580Overlay = final: prev:
		let
			base = if builtins.hasAttr "nvidiaPackages" prev then prev.nvidiaPackages else {};
		in
		if builtins.hasAttr "legacy_580" base then {
			nvidiaPackages = base // {
				legacy_580 = base.legacy_580.overrideAttrs (attrs: {
					postPatch = (attrs.postPatch or "") + ''
						substituteInPlace nvidia/os-interface.c --replace '#include <linux/sys_soc.h>' '#include <linux/sys_soc.h>\n#include <string.h>'
					'';
				});
			};
		} else {};
in

{
	nixpkgs.overlays = [ addLegacy580Overlay ];
}
 
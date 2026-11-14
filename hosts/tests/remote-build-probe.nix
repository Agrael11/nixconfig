{ pkgs, nonce, preferLocalBuild ? false }:
pkgs.runCommand "remote-build-probe-${nonce}" {
  allowSubstitutes = false;
  inherit preferLocalBuild;
} ''
  echo "probe: NIX_BUILD_CORES=$NIX_BUILD_CORES" >&2
  printf '%s\n' "$NIX_BUILD_CORES" > "$out"
  sleep 2
''

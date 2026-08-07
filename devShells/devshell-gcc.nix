({pkgs, pkgs-unstable, ...}: pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gdb
    cmake
    ninja
    pkg-config
    git
  ];

  shellHook = ''
    echo "Entered GCC development shell."
  '';
})
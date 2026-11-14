({ pkgs, inputs, ... }:
let
  withDirenv = ide: extraPlugins:
    (import "${inputs.jetbrains-plugins}/lib.nix").buildIdeWithPlugins pkgs ide (
      [ "io.github.salatmaster.direnv" ] ++ extraPlugins
    );

  vscodeCatalog = import "${inputs.vscode-extensions}/nix/overlay.nix" pkgs pkgs;
  marketplace = (vscodeCatalog.forVSCodeVersion pkgs.vscode.version).vscode-marketplace-release;
  vscodeWithExtensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = [
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.mkhl.direnv
    ] ++ (with marketplace; [
      ms-vscode.cpptools
      ms-vscode.cpp-devtools
      ms-vscode.cpptools-extension-pack
      ms-vscode.cpptools-themes
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      openai.chatgpt
      openai.codex-audio
    ]);
  };
in {
  # Graphical productivity applications.

  environment.systemPackages = with pkgs; [
    libreoffice
    davinci-resolve
    blender
    gimp
    vscodeWithExtensions
    obs-studio
    unityhub
    easyeffects
    rnnoise-plugin
    (withDirenv jetbrains.rust-rover [ ])
    (withDirenv jetbrains.clion [ ])
    (withDirenv jetbrains.rider [ "avalonia-rider" ])
    (withDirenv jetbrains.idea [ ])
  ];
})

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
  # Graphical development applications and their declarative plugins.

  environment.systemPackages = with pkgs; [
    vscodeWithExtensions
    unityhub
    (withDirenv jetbrains.rust-rover [ "com.intellij.plugins.visualstudiokeymap" ])
    (withDirenv jetbrains.clion [ "com.intellij.plugins.visualstudiokeymap" ])
    (withDirenv jetbrains.rider [ "avalonia-rider" "com.intellij.plugins.visualstudiokeymap" ])
    (withDirenv jetbrains.idea [ ])
  ];
})

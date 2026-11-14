# Instructions for coding agents working in nixconfig

This repository configures personal NixOS hosts `Desktop` (physical tower) and `Laptop`. Read `REFACTORING.md` before proposing or making structural changes.

## Scope and priorities

- Follow the **ordered, incremental** roadmap. Make the smallest practical diff for the currently requested step. Do not opportunistically rewrite unrelated files.
- Preserve existing behavior unless the user has explicitly agreed to a functional change. In particular, respect the user's latest-kernel preference, selective unstable packages, intentionally untracked `flake.lock`, aggressive garbage collection, disabled documentation, hidden Laptop boot menu, and remote-access tooling.
- The user wants content-based declarative package selection, *not* fixed dependency versions across time. Do not add `flake.lock` to Git or change update channels without express permission.
- `Desktop` means the **physical host**. Use `gui` to mean graphical applications and session functionality. CLI and GUI both have applications and services.
- Explicit per-host module imports are intended. Duplicate *selection lists* are fine; duplicated *implementations* should be avoided.
- Keep Nix `specialArgs` at the `nixosSystem`/flake level for now.

## Safety and testing

- Never execute `nixos-rebuild switch`, `boot`, `test`, or other activation commands without explicit user approval. Evaluation and builds may also consume significant space; explain before starting expensive builds.
- Do not modify secrets, passwords, remote access, firewall exposure, storage mounts, or boot behavior without first explaining proposed effects and receiving approval.
- Do not run destructive commands, garbage collection, filesystem cleanup, or remove generations without approval. Laptop free space was reported at roughly 30 MB; check free space before attempting builds there.
- Do not assume a flake evaluation proves that a kernel module or NVIDIA driver works. Report clearly whether a change was syntax-checked, evaluated, built, or runtime-tested.
- Don't automatically commit, push, merge, open PRs, or modify the remote repository unless requested.
- After each change, summarize files touched, behavior changes, commands/checks performed, and unverified assumptions.

## Known intentional workarounds

- Phase 7 retired the Laptop NVIDIA `strncpy` patch after unpatched 580.178.04 built against kernel 7.3.4 and produced identical kernel modules. Recheck compatibility when either updates.
- Desktop SC0710 now imports its upstream module directly: the old `stdenv` wrapper produced identical driver/helper derivations. Kernel packages still determine the driver's build environment.
- Phase 7 removed the obsolete VS Code `rg` workaround after an unmodified build and CLI/ripgrep checks. The removed MakeMKV overlay used the inactive typo `makmkv`; the installed `makemkv` was already upstream.
- Phase 7 restored RetroArch's `fbalpha2012` after a successful build and library/API check. Game playback remains a runtime check.
- `initialPassword = "Nix"` is an installation bootstrap convention; the user changes real passwords afterward. Treat credential verification as sensitive and never store passwords in Git.
- Sudo timeout, latest kernels, short garbage-retention policy, and zero-second Laptop GRUB menu are intentional choices, not refactoring targets by default.
- Phase 7 removed Desktop's kernel-7.0 logind workaround; normal power-management inhibitor handling is intentional.

## Collaboration

- The user maintains a separate ChatGPT web conversation for architecture and review; do not assume access to that conversation. `REFACTORING.md` is the shared plan.
- Ask before crossing phase boundaries or making surprising functional changes. Propose a minimal plan rather than implementing the entire roadmap in one pass.
- Avoid displaying code examples unless the user requests them; concise descriptions/diffs are preferable in conversation.

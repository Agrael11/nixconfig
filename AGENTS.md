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

- Laptop legacy NVIDIA 580 uses an imperfect `strncpy` workaround for kernel 7.2; do not remove blindly.
- Desktop SC0710 uses unstable `stdenv`; retest before removing.
- VS Code and MakeMKV overlays were added to work around upstream packaging failures. Verify current behavior before deleting.
- RetroArch sets the broken `fbalpha2012` core to `null` to exclude it from `retroarch-full`.
- `initialPassword = "Nix"` is an installation bootstrap convention; the user changes real passwords afterward. Treat credential verification as sensitive and never store passwords in Git.
- Sudo timeout, latest kernels, short garbage-retention policy, and zero-second Laptop GRUB menu are intentional choices, not refactoring targets by default.
- Desktop logind power-management inhibitor overrides were a workaround for kernel 7.0 and **are approved for removal** in the planned cleanup phase.

## Collaboration

- The user maintains a separate ChatGPT web conversation for architecture and review; do not assume access to that conversation. `REFACTORING.md` is the shared plan.
- Ask before crossing phase boundaries or making surprising functional changes. Propose a minimal plan rather than implementing the entire roadmap in one pass.
- Avoid displaying code examples unless the user requests them; concise descriptions/diffs are preferable in conversation.

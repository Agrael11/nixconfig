# Laptop → Desktop builds

The Laptop evaluates its own configuration. Its Nix daemon may send individual
builds to `nix-ssh@Desktop.local`, then copy the outputs back. Desktop never uses
Laptop as a builder. Ordinary `nixupdate` commands and their arguments stay the
same. Local Laptop jobs remain enabled, including while Desktop is online.

## Current configuration

- Laptop: two local jobs, four cores per job by default; its existing `.lightswitch.conf`
  and `nixupdate -j/--jobs -c/--cores` can override the local settings.
- Desktop: at most one remote job scheduled by this Laptop, with a default of
  four cores per build. This also changes Desktop's default for direct Nix builds;
  `nixupdate` already requested four cores. Explicit Desktop CLI overrides still work.
- `ssh-ng` in Nix 2.34.9 does **not** forward Laptop's `cores` option to Desktop.
  Laptop's `-c` is not a remote CPU limit. The defaults are build hints, not hard
  CPU quotas; some builders ignore them. There is no load-aware gaming detector.
- `speedFactor` weights remote builders against one another; it does not force
  all work off Laptop. A busy Desktop may queue work; busy/concurrent behavior
  still needs physical-host testing.
- Desktop can fetch dependencies from its own configured binary cache. Finished
  closures still occupy Laptop's store. This is not a storage-saving mechanism.
- The `nix-ssh` account is restricted to the Nix protocol, with public-key-only
  authentication and no forwarding or terminal. It is a trusted Nix user, which
  grants powerful store/build access. Authorize only Laptop's dedicated key.
- Desktop's public Ed25519 host key is pinned in `hosts/laptop/remote-builds.nix`.
  If Desktop is reinstalled or its host key changes, verify the new key directly
  on Desktop and update that declaration. Do not disable host-key checking.

## One-time setup

No private keys belong in this repository or in a Nix expression. No setup command
below activates a system. Apply each host configuration yourself when ready.

1. On **Laptop**, check capacity and discovery before any build:

   ```sh
   df -h /nix/store
   getent ahostsv4 Desktop.local
   ```

   Stop if disk space is critically low. Do not delete working generations to run
   these tests. mDNS needs a multicast-capable local network; `.local` discovery
   is not guaranteed across routed/VPN networks.

2. On **Laptop**, create a dedicated key only if it does not already exist:

   ```sh
   sudo install -d -m 0700 /var/lib/nix-remote-build
   sudo test -e /var/lib/nix-remote-build/id_ed25519 ||
     sudo ssh-keygen -t ed25519 -N '' -C Laptop-to-Desktop-builder \
       -f /var/lib/nix-remote-build/id_ed25519
   sudo chmod 0600 /var/lib/nix-remote-build/id_ed25519
   sudo ssh-keygen -lf /var/lib/nix-remote-build/id_ed25519.pub
   sudo cat /var/lib/nix-remote-build/id_ed25519.pub
   ```

3. Copy **only that public key** to `/tmp/laptop-builder.pub` on Desktop using
   your existing access. Compare its fingerprint to step 2, then on **Desktop**:

   ```sh
   ssh-keygen -lf /tmp/laptop-builder.pub
   sudo install -d -m 0755 /var/lib/nix-remote-builder
   sudo install -o root -g root -m 0644 /tmp/laptop-builder.pub \
     /var/lib/nix-remote-builder/authorized_keys
   ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
   ```

   The root-owned public-key file is read at runtime; it is deliberately not
   copied into the Nix store. Keep the private key only on Laptop. A missing
   authorization file prevents remote authentication and leaves local fallback.

4. After you apply the prepared configurations on both hosts, run on **Laptop**:

   ```sh
   sudo nix store info --store \
     'ssh-ng://nix-ssh@Desktop.local?ssh-key=/var/lib/nix-remote-build/id_ed25519'
   ```

   This checks Nix protocol access without building or activating. A regular shell
   login as `nix-ssh` is intentionally unavailable. A host-key error must be
   resolved by comparing Desktop's actual public host key with the pinned key.

## Safe update-script checks

From the repository root, on either machine:

```sh
python3 hosts/tests/test-update.py
```

This copies `update.sh` into a temporary directory with a temporary home and fake
`nh`/`sudo` commands. It tests setup/symlinks, defaults, config and CLI overrides,
dummy token forwarding, boot/switch, power-action precedence, clean/all, invalid
arguments, and failure handling. It never activates, reboots, suspends, or cleans
the real system, and never reads the real `.lightswitch.conf` or token.

The installed nh 4.4.2 forwards the arguments following `--` to the build command.
Its `--dry` flag does not prevent building for `nh os build`; for switch/boot it
skips activation only after building. Do not use ordinary `nixupdate` as a dry run:
the script has no dry-run flag and defaults to activation. The mock harness tests
that exact entry point safely. Live `--update` refreshes Laptop's own input
resolution; remote builders receive store inputs/derivations and do not need a
checkout or a separately committed lock file. `flake.lock` stays untracked.

## Small physical-host tests

On **Laptop**, from the repository root, define this helper in a test terminal:

```sh
probe() {
  PROBE_NONCE="$(date +%s)-$$-$1" nix build --impure --no-link -L \
    --option max-jobs 1 --option cores 1 \
    --expr 'let
      f = builtins.getFlake ("git+file://" + toString ./.);
    in import ./hosts/tests/remote-build-probe.nix {
      pkgs = f.nixosConfigurations.Laptop.pkgs;
      nonce = builtins.getEnv "PROBE_NONCE";
    }' "${@:2}"
}
```

Use a new label for every invocation to prevent reusing an earlier result.
The probe writes one line and sleeps two seconds. Check disk space first and
inspect downloads with `probe plan --dry-run` before running it. These commands
build only the probe, without updating inputs or activating either host.

1. **Online:** `probe online`. Save the log showing `building ... on
   ssh-ng://nix-ssh@Desktop.local`. Check on Desktop with `pgrep -af nix` or the
   daemon journal while it runs. Its output reports Desktop's four-core default.
   A successful local-only result does not prove offloading.
2. **Local control:** `probe local --builders ''`. The log/output should show a
   local build using the requested one core.
3. **Unreachable SSH simulation:** `probe unavailable --builders
   'ssh-ng://nix-ssh@127.0.0.1:1 x86_64-linux - 1 2 - -'`. Confirm a failed remote
   connection followed by a successful local build. This leaves real SSH and the
   network untouched. Also repeat the ordinary probe with Desktop physically off
   when convenient, to check real name-resolution/connect timeouts.
4. **Recovery:** `probe recovered` after Desktop becomes reachable again. Confirm
   the remote-build log returns. Recovery within a single failed build is not
   guaranteed; Nix may disable a failing builder for that invocation.
5. **Busy/concurrent:** run probes with different labels from two Laptop terminals
   while Desktop is doing a build you already intended to run. Observe remote
   concurrency, local scheduling and interactivity; do not manufacture a large
   kernel rebuild just to create load. A remote job's compiler failure is a build
   failure, not a promise to retry locally.

Before calling Phase 9 complete, also validate an ordinary Laptop system build
through `nh os build` (without activation), the next user-approved normal update
on each machine, and behavior while both update simultaneously. Keep the small
probe evidence separate from full workflow validation. No test here authorizes
activation, cleanup, reboot, or changing either host's SSH credentials remotely.

## References checked

- [Nix 2.34 remote builds](https://nix.dev/manual/nix/2.34/advanced-topics/distributed-builds.html)
- [Nix 2.34 cores and jobs](https://nix.dev/manual/nix/2.34/advanced-topics/cores-vs-jobs.html)
- [Nix 2.34.9 ssh-ng option forwarding](https://github.com/NixOS/nix/blob/2.34.9/src/libstore/ssh-store.cc)
- [nh 4.4.2 argument forwarding and build/activation flow](https://github.com/nix-community/nh/blob/v4.4.2/crates/nh-nixos/src/nixos.rs)

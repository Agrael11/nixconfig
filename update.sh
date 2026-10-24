#!/usr/bin/env bash
set -euo pipefail

# Spoľahlivo zistí reálny adresár skriptu aj v prípade, že je spustený cez symlink z PATH
SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd)"
cd "$SCRIPT_DIR"

CONFIG_FILE="$SCRIPT_DIR/.lightswitch.conf"

# Predvolené hodnoty
MAX_JOBS=2
CORES=4
GITHUB_TOKEN=""

# Načítanie konfigurácie, ak existuje
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi
}

# Samotný setup (interaktívny)
cmd_setup() {
    echo "=== Nix Update Setup ==="
    
    read -r -s -p "GitHub token (leave empty for none): " TOKEN
    echo
    read -r -p "Default max jobs [$MAX_JOBS]: " input_jobs
    MAX_JOBS="${input_jobs:-$MAX_JOBS}"
    
    read -r -p "Default cores per job [$CORES]: " input_cores
    CORES="${input_cores:-$CORES}"

    if ! [[ "$MAX_JOBS" =~ ^[1-9][0-9]*$ && "$CORES" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Jobs and cores must be positive integers." >&2
        exit 1
    fi

    cat > "$CONFIG_FILE" <<EOF
MAX_JOBS=$MAX_JOBS
CORES=$CORES
GITHUB_TOKEN="$TOKEN"
EOF
    chmod 600 "$CONFIG_FILE"
    echo "Configuration saved to $CONFIG_FILE"

    # Použijeme štandardný a čistý ~/.local/bin
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    
    local symlink_path="$bin_dir/nixupdate"
    ln -sf "$SCRIPT_DIR/update.sh" "$symlink_path"
    echo "Symlink created at $symlink_path"
    
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        echo "Note: $bin_dir is not currently in your PATH."
        echo "You may want to add it to your shell configuration or home-manager."
    fi
}

# Čistenie systému
cmd_clean() {
    echo "Cleaning up system..."
    nh clean all
}

# Hlavná logika pre update / switch / boot / reboot
cmd_update() {
    local action="switch"
    local do_reboot=false

    # Ak nie je spravený setup, pustíme ho automaticky
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Configuration not found. Running setup first..."
        cmd_setup
    fi

    load_config

    # Parsovanie flagov špecifických pre update akciu
    while [[ $# -gt 0 ]]; do
        case "$1" in
            boot)
                action="boot"
                shift
                ;;
            reboot|--reboot)
                action="boot"
                do_reboot=true
                shift
                ;;
            -j|--jobs)
                [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
                MAX_JOBS="$2"
                shift 2
                ;;
            -c|--cores)
                [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
                CORES="$2"
                shift 2
                ;;
            *)
                echo "Unknown flag: $1" >&2
                exit 1
                ;;
        esac
    done

    # Validácia
    if ! [[ "$MAX_JOBS" =~ ^[1-9][0-9]*$ && "$CORES" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Jobs and cores must be positive integers." >&2
        exit 1
    fi

    # Zostavenie extra argumentov pre nix
    local extra_args=()
    if [[ -n "$GITHUB_TOKEN" ]]; then
        extra_args+=("--option" "access-tokens" "github.com=$GITHUB_TOKEN")
    fi

    echo "Running nh os $action (jobs: $MAX_JOBS, cores: $CORES)..."
    nh os "$action" --update -- \
        --option max-jobs "$MAX_JOBS" \
        --option cores "$CORES" \
        "${extra_args[@]}"

    if [[ "$do_reboot" == true ]]; then
        echo "Rebooting system..."
        sudo reboot
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [command] [options]

Commands:
  (none / update)    Run system update/switch (default, auto-runs setup if missing)
  setup              Configure tokens, jobs, cores and create 'nixupdate' symlink
  clean              Run 'nh clean all'
  all                Run 'clean' followed by 'update'

Update Options:
  boot               Perform 'nh os boot' instead of 'switch'
  reboot, --reboot   Perform 'nh os boot' and then reboot the machine
  -j, --jobs NUM     Override max jobs
  -c, --cores NUM    Override cores per job
  -h, --help         Show this help message
EOF
}

# Hlavný vstupný bod s implicitným "update"
if [[ $# -eq 0 ]]; then
    cmd_update
    exit 0
fi

case "$1" in
    setup)
        cmd_setup
        ;;
    clean)
        cmd_clean
        ;;
    update)
        shift
        cmd_update "$@"
        ;;
    all)
        shift
        cmd_clean
        cmd_update "$@"
        ;;
    -h|--help)
        usage
        ;;
    boot|reboot|--reboot|-j|--jobs|-c|--cores)
        cmd_update "$@"
        ;;
    *)
        echo "Unknown command: $1" >&2
        usage >&2
        exit 1
        ;;
esac
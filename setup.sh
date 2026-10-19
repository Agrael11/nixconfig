
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/lightswitch.sh"

if [[ -e "$TARGET" ]]; then
    echo "lightswitch.sh already exists."
    exit 1
fi

read -r -s -p "GitHub token (leave empty for none): " TOKEN
echo

read -r -p "Default max jobs [2]: " MAX_JOBS
MAX_JOBS="${MAX_JOBS:-2}"

read -r -p "Default cores per job [4]: " CORES
CORES="${CORES:-4}"

if ! [[ "$MAX_JOBS" =~ ^[1-9][0-9]*$ &&
        "$CORES" =~ ^[1-9][0-9]*$ ]]; then
    echo "Jobs and cores must be positive integers." >&2
    exit 1
fi

# Generate lightswitch.sh
{
    cat <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

ACTION="switch"
SCRIPT

    printf 'MAX_JOBS=%q\n' "$MAX_JOBS"
    printf 'CORES=%q\n' "$CORES"

    if [[ -n "$TOKEN" ]]; then
        printf 'NIX_CONFIG="access-tokens = github.com=%s"\n' "$TOKEN"
        echo 'export NIX_CONFIG'
    fi

    cat <<'SCRIPT'

usage() {
    echo "Usage: $0 [boot] [-j JOBS] [-c CORES]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        boot)
            ACTION="boot"
            shift
            ;;
        -j|--jobs)
            [[ $# -ge 2 ]] || { usage; exit 1; }
            MAX_JOBS="$2"
            shift 2
            ;;
        -c|--cores)
            [[ $# -ge 2 ]] || { usage; exit 1; }
            CORES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac
done

if ! [[ "$MAX_JOBS" =~ ^[1-9][0-9]*$ &&
        "$CORES" =~ ^[1-9][0-9]*$ ]]; then
    echo "Jobs and cores must be positive integers." >&2
    exit 1
fi

nh os "$ACTION" --update -- \
    --option max-jobs "$MAX_JOBS" \
    --option cores "$CORES"
SCRIPT
} > "$TARGET"

chmod 700 "$TARGET"
echo "Created lightswitch.sh"

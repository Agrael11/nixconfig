#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f "./lightswitch.sh" ]]; then
    echo "lightswitch.sh not found. Running setup..."
    ./setup.sh
fi

./lightswitch.sh "$@"
nh clean all

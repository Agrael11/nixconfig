{ pkgs, ... }:

let
  mountisoScript = pkgs.writeShellApplication {
    name = "mountiso";
    runtimeInputs = [ pkgs.util-linux pkgs.coreutils pkgs.fuseiso ];
    text = ''
      #!/usr/bin/env bash
      set -e

      MOUNT_DIR="/media/iso"
      IMAGE_FILE="$1"

      if [ -z "$IMAGE_FILE" ] || [ ! -f "$IMAGE_FILE" ]; then
          echo "Usage: mountiso <path_to_image.(iso|cue|bin|mdf)>"
          exit 1
      fi

      if [ ! -d "$MOUNT_DIR" ]; then
          echo "Creating directory $MOUNT_DIR..."
          sudo mkdir -p "$MOUNT_DIR"
      fi

      if mountpoint -q "$MOUNT_DIR" || grep -qs "$MOUNT_DIR" /proc/mounts; then
          echo "Unmounting $MOUNT_DIR..."
          if command -v fusermount &> /dev/null && fusermount -u "$MOUNT_DIR" 2>/dev/null; then
              true
          else
              sudo umount "$MOUNT_DIR"
          fi
      fi

      # Fixed extension extraction for Bash
      EXT="''${IMAGE_FILE##*.}"
      EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

      echo "Mounting $IMAGE_FILE to $MOUNT_DIR..."

      case "$EXT_LOWER" in
          iso|bin)
              sudo mount -o loop "$IMAGE_FILE" "$MOUNT_DIR"
              ;;
          cue|mdf|mds)
              if command -v fuseiso &> /dev/null; then
                  fuseiso "$IMAGE_FILE" "$MOUNT_DIR"
              else
                  sudo mount -o loop "$IMAGE_FILE" "$MOUNT_DIR"
              fi
              ;;
          *)
              sudo mount -o loop "$IMAGE_FILE" "$MOUNT_DIR"
              ;;
      esac

      echo "Successfully mounted!"
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    mountisoScript
    util-linux
    coreutils
    fuseiso
  ];
}
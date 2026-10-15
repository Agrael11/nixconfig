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
          echo "Usage: mountiso <path_to_image.(iso|cue|bin|mdf|mds)>"
          exit 1
      fi

      USER_ID=$(id -u)
      GROUP_ID=$(id -g)

      # Ensure /media/iso exists and is owned by your user using numeric IDs
      if [ ! -d "$MOUNT_DIR" ]; then
          sudo  mkdir -p "$MOUNT_DIR"
          sudo chown "$USER_ID:$GROUP_ID" "$MOUNT_DIR"
      elif [ ! -O "$MOUNT_DIR" ]; then
          sudo chown "$USER_ID:$GROUP_ID" "$MOUNT_DIR"
      fi

      # Unmount if already active
      if mountpoint -q "$MOUNT_DIR" || grep -qs "$MOUNT_DIR" /proc/mounts; then
          echo "Unmounting $MOUNT_DIR..."
          fusermount -u "$MOUNT_DIR" 2>/dev/null || sudo umount "$MOUNT_DIR" 2>/dev/null || true
      fi

      EXT="''${IMAGE_FILE##*.}"
      EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

      echo "Mounting $IMAGE_FILE to $MOUNT_DIR..."

      case "$EXT_LOWER" in
          iso|bin)
              sudo mount -o loop,uid="$USER_ID",gid="$GROUP_ID",umask=022 "$IMAGE_FILE" "$MOUNT_DIR"
              ;;
          cue|mdf|mds)
              if command -v fuseiso &> /dev/null; then
                  # Run fuseiso directly as user since MOUNT_DIR is user-owned
                  fuseiso "$IMAGE_FILE" "$MOUNT_DIR"
              else
                  echo "Error: fuseiso is required for .$EXT_LOWER files."
                  exit 1
              fi
              ;;
          *)
              sudo mount -o loop,uid="$USER_ID",gid="$GROUP_ID",umask=022 "$IMAGE_FILE" "$MOUNT_DIR"
              ;;
      esac

      echo "Successfully mounted and accessible!"
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
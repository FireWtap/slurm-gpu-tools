#!/usr/bin/env bash
# Symlink every tool in bin/ into ~/.local/bin (or $PREFIX/bin). Existing non-symlink files are left alone.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; dest="${PREFIX:-$HOME/.local}/bin"; mkdir -p "$dest"
for f in "$here"/bin/*; do
  t="$dest/$(basename "$f")"
  if [[ -e "$t" && ! -L "$t" ]]; then echo "skip $t (exists, not a symlink; move it away first)"; continue; fi
  ln -sfn "$f" "$t"; echo "linked $t -> $f"
done
case ":$PATH:" in *":$dest:"*) ;; *) echo "note: add $dest to your PATH";; esac

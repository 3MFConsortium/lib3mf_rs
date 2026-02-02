#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

LIB_DIR="$ROOT_DIR/libraries"
TARGET_DIR="$ROOT_DIR/target"
EXE_DIR="$TARGET_DIR/examples"
DEFAULT_3MF="$ROOT_DIR/data/cube.3mf"

mkdir -p "$EXE_DIR"

cargo build --offline

rustc --edition 2021 examples/version.rs \
  -L target/debug \
  --extern lib3mf=target/debug/liblib3mf.rlib \
  -o "$EXE_DIR/version"

rustc --edition 2021 examples/create_cube.rs \
  -L target/debug \
  --extern lib3mf=target/debug/liblib3mf.rlib \
  -o "$EXE_DIR/create_cube"

rustc --edition 2021 examples/read_meshes.rs \
  -L target/debug \
  --extern lib3mf=target/debug/liblib3mf.rlib \
  -o "$EXE_DIR/read_meshes"

UNAME_S="$(uname -s)"
case "$UNAME_S" in
  Darwin)
    export DYLD_LIBRARY_PATH="$LIB_DIR${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
    ;;
  Linux)
    export LD_LIBRARY_PATH="$LIB_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    ;;
  *)
    echo "Warning: unsupported OS '$UNAME_S' for automatic library path setup."
    ;;
esac

"$EXE_DIR/version"
"$EXE_DIR/create_cube"

if [[ $# -ge 1 ]]; then
  "$EXE_DIR/read_meshes" "$@"
elif [[ -f "$DEFAULT_3MF" ]]; then
  "$EXE_DIR/read_meshes" "$DEFAULT_3MF"
else
  echo "Skipping read_meshes (provide a 3MF file path as an argument)"
fi

echo "Done. Output file: $ROOT_DIR/cube.3mf"

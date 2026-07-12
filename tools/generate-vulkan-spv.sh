#!/bin/bash
# Regenerate Source/Cmlx/mlx-generated/vulkan/vulkan_spirv.h from the mlx
# submodule's Vulkan shader generator. Requires slangc (Slang compiler) on
# PATH or at SLANGC.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MLX="$ROOT/Source/Cmlx/mlx"
SLANGC="${SLANGC:-$(command -v slangc || echo /Users/kennywalker/Documents/Developer/MLX/tools/slang/bin/slangc)}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

python3 "$MLX/mlx/backend/vulkan/shaders/gen_shaders.py" --out-dir "$WORK/slang"
mkdir -p "$WORK/spv"
n=0
for f in "$WORK"/slang/*.slang; do
  name="$(basename "$f" .slang)"
  "$SLANGC" "$f" -target spirv -O2 -o "$WORK/spv/$name.spv" &
  n=$((n + 1))
  if [ $((n % 8)) -eq 0 ]; then wait; fi
done
wait

mkdir -p "$ROOT/Source/Cmlx/mlx-generated/vulkan"
python3 "$MLX/mlx/backend/vulkan/shaders/embed_spirv.py" \
  --spv-dir "$WORK/spv" \
  --out "$ROOT/Source/Cmlx/mlx-generated/vulkan/vulkan_spirv.h"
echo "Wrote $ROOT/Source/Cmlx/mlx-generated/vulkan/vulkan_spirv.h"

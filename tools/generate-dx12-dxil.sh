#!/bin/bash
# Regenerate Source/Cmlx/mlx-generated/dx12/dx12_dxil.h from the mlx
# submodule's shader generator (DirectX 12 / DXIL variant of
# generate-vulkan-spv.sh).
#
# IMPORTANT: unlike the Vulkan flow, the compile step CANNOT run on macOS.
# Emitting DXIL requires slangc.exe plus a signing-capable dxil.dll, both of
# which are Windows-only (expected at C:\mlxtools on the build machine). Run
# this script on Windows (Git Bash / MSYS), or run only the generation step
# here and copy the .slang files over.
#
# Assumptions (these scripts are provided by the mlx submodule's dx12 work
# and may not have landed yet — check mlx/mlx/backend/vulkan/shaders/):
#   * gen_shaders.py accepts `--api dx12` and emits HLSL-compatible .slang
#     sources into --out-dir.
#   * shaders/compile_dxil.py wraps slangc.exe (-target dxil) and dxil.dll
#     signing; SLANGC / DXIL_DLL point at C:\mlxtools by default.
#   * shaders/embed_dxil.py packs the .dxil blobs into a C header, like
#     embed_spirv.py does for SPIR-V.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MLX="$ROOT/Source/Cmlx/mlx"
SHADERS="$MLX/mlx/backend/vulkan/shaders"
SLANGC="${SLANGC:-C:/mlxtools/slangc.exe}"
DXIL_DLL="${DXIL_DLL:-C:/mlxtools/dxil.dll}"

if [[ "$(uname -s)" != MINGW* && "$(uname -s)" != MSYS* && "$(uname -s)" != CYGWIN* ]]; then
    echo "warning: DXIL compilation requires Windows (slangc.exe + dxil.dll)." >&2
    echo "warning: only the shader *generation* step will work on this host." >&2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 1. Generate the shader sources for the dx12 API variant.
python3 "$SHADERS/gen_shaders.py" --api dx12 --out-dir "$WORK/slang"

# 2. Compile each shader to signed DXIL (Windows only).
python3 "$SHADERS/compile_dxil.py" \
    --slangc "$SLANGC" \
    --dxil-dll "$DXIL_DLL" \
    --in-dir "$WORK/slang" \
    --out-dir "$WORK/dxil"

# 3. Embed the DXIL blobs into the generated header.
mkdir -p "$ROOT/Source/Cmlx/mlx-generated/dx12"
python3 "$SHADERS/embed_dxil.py" \
    --dxil-dir "$WORK/dxil" \
    --out "$ROOT/Source/Cmlx/mlx-generated/dx12/dx12_dxil.h"
echo "Wrote $ROOT/Source/Cmlx/mlx-generated/dx12/dx12_dxil.h"

# mlx-generated/dx12

Placeholder for the generated `dx12_dxil.h` header that embeds the
precompiled DXIL shader blobs for the DirectX 12 backend
(`SPM_DX12=1` builds).

Regenerate with `tools/generate-dx12-dxil.sh` (the DXIL compile step must
run on a Windows machine with `slangc.exe` and `dxil.dll` available, e.g.
under `C:\mlxtools`). This mirrors `mlx-generated/vulkan/vulkan_spirv.h`,
which is produced by `tools/generate-vulkan-spv.sh`.

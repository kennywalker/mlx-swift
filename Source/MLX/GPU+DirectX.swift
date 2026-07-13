// Copyright © 2026 Apple Inc.

import Cmlx
import Foundation

/// API for controlling GPU related features (DirectX 12 backend).
///
/// Note: memory management properties are found in ``Memory``.
///
/// ### See Also
/// - ``Memory``
public enum GPU {

    /// Returns the GPU's recommended working set size in bytes as an `Int`.
    ///
    /// On the DirectX 12 backend this is derived from the adapter's dedicated
    /// video memory reported by DXGI. Returns `nil` when unavailable.
    public static func maxRecommendedWorkingSetBytes() -> Int? {
        // TODO: expose DXGI_ADAPTER_DESC / DXGI_QUERY_VIDEO_MEMORY_INFO
        // through a small mlx-c shim (mlx_dx12_device_info) and return it
        // here.
        return nil
    }
}

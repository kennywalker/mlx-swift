// Copyright © 2026 Apple Inc.

import Cmlx
import Foundation

/// API for controlling GPU related features (Vulkan backend).
///
/// Note: memory management properties are found in ``Memory``.
///
/// ### See Also
/// - ``Memory``
public enum GPU {

    /// Returns the GPU's recommended working set size in bytes as an `Int`.
    ///
    /// On the Vulkan backend this is derived from the device-local heap size
    /// reported by the driver. Returns `nil` when unavailable.
    public static func maxRecommendedWorkingSetBytes() -> Int? {
        // TODO: expose VkPhysicalDeviceMemoryProperties heap size through a
        // small mlx-c shim (mlx_vulkan_device_info) and return it here.
        return nil
    }
}

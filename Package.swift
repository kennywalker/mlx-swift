// swift-tools-version: 6.3;(experimentalCGen)
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2024 Apple Inc.

import PackageDescription

let noMetalCmlxExcludes = [
    // Exclude Metal backend files, but keep no_metal.cpp for stubs
    // "mlx/mlx/backend/metal/no_metal.cpp",
    "mlx/mlx/backend/metal/allocator.cpp",
    "mlx/mlx/backend/metal/binary.cpp",
    "mlx/mlx/backend/metal/compiled.cpp",
    "mlx/mlx/backend/metal/conv.cpp",
    "mlx/mlx/backend/metal/copy.cpp",
    "mlx/mlx/backend/metal/custom_kernel.cpp",
    "mlx/mlx/backend/metal/device.cpp",
    "mlx/mlx/backend/metal/device_info.cpp",
    "mlx/mlx/backend/metal/distributed.cpp",
    "mlx/mlx/backend/metal/eval.cpp",
    "mlx/mlx/backend/metal/event.cpp",
    "mlx/mlx/backend/metal/fence.cpp",
    "mlx/mlx/backend/metal/fft.cpp",
    "mlx/mlx/backend/metal/hadamard.cpp",
    "mlx/mlx/backend/metal/indexing.cpp",
    "mlx/mlx/backend/metal/jit_kernels.cpp",
    "mlx/mlx/backend/metal/logsumexp.cpp",
    "mlx/mlx/backend/metal/matmul.cpp",
    "mlx/mlx/backend/metal/metal.cpp",
    "mlx/mlx/backend/metal/normalization.cpp",
    "mlx/mlx/backend/metal/primitives.cpp",
    "mlx/mlx/backend/metal/quantized.cpp",
    "mlx/mlx/backend/metal/reduce.cpp",
    "mlx/mlx/backend/metal/resident.cpp",
    "mlx/mlx/backend/metal/rope.cpp",
    "mlx/mlx/backend/metal/scaled_dot_product_attention.cpp",
    "mlx/mlx/backend/metal/scan.cpp",
    "mlx/mlx/backend/metal/slicing.cpp",
    "mlx/mlx/backend/metal/softmax.cpp",
    "mlx/mlx/backend/metal/sort.cpp",
    "mlx/mlx/backend/metal/ternary.cpp",
    "mlx/mlx/backend/metal/unary.cpp",
    "mlx/mlx/backend/metal/utils.cpp",
    "mlx/mlx/backend/metal/kernels",  // Exclude kernels directory
    "mlx/mlx/backend/metal/jit",  // Exclude jit directory
]

let noCudaCmlxExcludes = [
    // Exclude CUDA backend files, but keep no_cuda.cpp for stubs
    // mlx/mlx/backend/cuda/no_cuda.cpp
    "mlx/mlx/backend/cuda/allocator.cpp",
    "mlx/mlx/backend/cuda/compiled.cpp",
    "mlx/mlx/backend/cuda/conv.cpp",
    "mlx/mlx/backend/cuda/cublas_utils.cpp",
    "mlx/mlx/backend/cuda/cudnn_utils.cpp",
    "mlx/mlx/backend/cuda/custom_kernel.cpp",
    "mlx/mlx/backend/cuda/delayload.cpp",
    "mlx/mlx/backend/cuda/device_info.cpp",
    "mlx/mlx/backend/cuda/device.cpp",
    "mlx/mlx/backend/cuda/eval.cpp",
    "mlx/mlx/backend/cuda/fence.cpp",
    "mlx/mlx/backend/cuda/indexing.cpp",
    "mlx/mlx/backend/cuda/jit_module.cpp",
    "mlx/mlx/backend/cuda/load.cpp",
    "mlx/mlx/backend/cuda/matmul.cpp",
    "mlx/mlx/backend/cuda/primitives.cpp",
    "mlx/mlx/backend/cuda/scaled_dot_product_attention.cpp",
    "mlx/mlx/backend/cuda/slicing.cpp",
    "mlx/mlx/backend/cuda/utils.cpp",
    "mlx/mlx/backend/cuda/worker.cpp",
    "mlx/mlx/backend/cuda/binary",
    "mlx/mlx/backend/cuda/conv",
    "mlx/mlx/backend/cuda/copy",
    "mlx/mlx/backend/cuda/device",
    "mlx/mlx/backend/cuda/gemms",
    "mlx/mlx/backend/cuda/quantized",
    "mlx/mlx/backend/cuda/reduce",
    "mlx/mlx/backend/cuda/steel",
    "mlx/mlx/backend/cuda/unary",
]

let noVulkanCmlxExcludes = [
    // Exclude the whole Vulkan backend. Nothing outside it references the
    // vk:: symbols, so the no_vulkan.cpp stub is not needed either.
    "mlx/mlx/backend/vulkan"
]

let noDX12CmlxExcludes = [
    // Exclude the whole DirectX 12 backend (mirrors the Vulkan handling).
    "mlx/mlx/backend/dx12"
]

// The Vulkan backend (Android and other Vulkan platforms) is selected with
// SPM_VULKAN=1 in the environment rather than by `#if os(...)` because the
// manifest is evaluated on the build host, not the target (e.g. when
// cross-compiling to Android from macOS).
let vulkanBuild = Context.environment["SPM_VULKAN"] == "1"

// The DirectX 12 backend (Windows) is selected with SPM_DX12=1 for the same
// reason: `#if os(...)` in the manifest evaluates on the build host.
let dx12Build = Context.environment["SPM_DX12"] == "1"

let platformExcludes: [String]
let cxxSettings: [CXXSetting]
let linkerSettings: [LinkerSetting]
let mlxSwiftExcludes: [String]

if dx12Build {
    // DirectX 12 GPU backend + CPU backend (OpenBLAS), Windows.
    //
    // OpenBLAS is consumed the same way as the Vulkan/Android build:
    // MLX_OPENBLAS_PATH points at a prebuilt with include/ + lib/. The
    // Windows prebuilt (C:\mlxtools\OpenBLAS on the build machine) nests
    // headers in include/openblas/ and ships lib/openblas.lib, so both
    // include layouts are added below.
    let openblas = Context.environment["MLX_OPENBLAS_PATH"]
        ?? "C:/mlxtools/OpenBLAS"

    platformExcludes =
        [
            "framework",
            "include-framework",
            "metal-cpp",

            "mlx/mlx/backend/no_gpu",

            // The CPU backend is used, but there is no on-device C++ JIT:
            // compile no_cpu/compiled.cpp instead of cpu/compiled.cpp and
            // exclude the rest of no_cpu.
            "mlx/mlx/backend/cpu/compiled.cpp",
            "mlx/mlx/backend/cpu/jit_compiler.cpp",
            "mlx/mlx/backend/no_cpu/allocator.cpp",
            "mlx/mlx/backend/no_cpu/device_info.cpp",
            "mlx/mlx/backend/no_cpu/eval.cpp",
            "mlx/mlx/backend/no_cpu/event.cpp",
            "mlx/mlx/backend/no_cpu/fence.cpp",
            "mlx/mlx/backend/no_cpu/primitives.cpp",
            "mlx/mlx/backend/no_cpu/CMakeLists.txt",

            "mlx/mlx/backend/cpu/gemms/bnns.cpp",  // macOS Accelerate version
            "mlx-conditional",
            "mlx-c/mlx/c/metal.cpp",

            // DX12 backend: build the real thing, not the stub; shaders are
            // precompiled into mlx-generated/dx12/dx12_dxil.h.
            "mlx/mlx/backend/dx12/no_dx12.cpp",
            "mlx/mlx/backend/dx12/CMakeLists.txt",
            "mlx/mlx/backend/dx12/shaders",
        ] + noMetalCmlxExcludes + noCudaCmlxExcludes + noVulkanCmlxExcludes

    cxxSettings = [
        .headerSearchPath("mlx-generated/dx12"),
        .headerSearchPath("mlx/mlx/backend/dx12/vendor/directx-headers/include"),
        .headerSearchPath("mlx/mlx/backend/dx12/vendor/d3d12ma"),
        .define("MLX_USE_DX12"),
        // mlx's CMake defines these for MSVC/Windows builds (CMakeLists:54);
        // without them windows.h's min/max macros poison the mlx headers.
        .define("NOMINMAX"),
        .define("WIN32_LEAN_AND_MEAN"),
        .unsafeFlags(["-I\(openblas)/include"]),
        .unsafeFlags(["-I\(openblas)/include/openblas"]),
    ]

    // No d3d12/dxgi import libraries: the backend loads d3d12.dll and
    // dxgi.dll at runtime via LoadLibrary.
    linkerSettings = [
        .unsafeFlags(["-L\(openblas)/lib"]),
        .linkedLibrary("openblas"),
    ]

    mlxSwiftExcludes = [
        "GPU+Metal.swift",
        "GPU+CUDA.swift",
        "GPU+Vulkan.swift",
        "MLXArray+Metal.swift",
    ]
} else if vulkanBuild {
    // Vulkan GPU backend + CPU backend (OpenBLAS), typically Android.
    let openblas = Context.environment["MLX_OPENBLAS_PATH"]
        ?? "/Users/kennywalker/Documents/Developer/MLX/prebuilt/openblas-android/arm64-v8a"

    platformExcludes =
        [
            "framework",
            "include-framework",
            "metal-cpp",

            "mlx/mlx/backend/no_gpu",

            // The CPU backend is used, but there is no on-device C++ JIT:
            // compile no_cpu/compiled.cpp instead of cpu/compiled.cpp and
            // exclude the rest of no_cpu.
            "mlx/mlx/backend/cpu/compiled.cpp",
            "mlx/mlx/backend/cpu/jit_compiler.cpp",
            "mlx/mlx/backend/no_cpu/allocator.cpp",
            "mlx/mlx/backend/no_cpu/device_info.cpp",
            "mlx/mlx/backend/no_cpu/eval.cpp",
            "mlx/mlx/backend/no_cpu/event.cpp",
            "mlx/mlx/backend/no_cpu/fence.cpp",
            "mlx/mlx/backend/no_cpu/primitives.cpp",
            "mlx/mlx/backend/no_cpu/CMakeLists.txt",

            "mlx/mlx/backend/cpu/gemms/bnns.cpp",  // macOS Accelerate version
            "mlx-conditional",
            "mlx-c/mlx/c/metal.cpp",

            // Vulkan backend: build the real thing, not the stub; shaders are
            // precompiled into mlx-generated/vulkan/vulkan_spirv.h.
            "mlx/mlx/backend/vulkan/no_vulkan.cpp",
            "mlx/mlx/backend/vulkan/CMakeLists.txt",
            "mlx/mlx/backend/vulkan/shaders",
        ] + noMetalCmlxExcludes + noCudaCmlxExcludes + noDX12CmlxExcludes

    cxxSettings = [
        .headerSearchPath("mlx-generated/vulkan"),
        .headerSearchPath("mlx/mlx/backend/vulkan/vendor/volk"),
        .headerSearchPath("mlx/mlx/backend/vulkan/vendor/vma"),
        .define("MLX_USE_VULKAN"),
        .define("VK_NO_PROTOTYPES"),
        .define("VMA_STATIC_VULKAN_FUNCTIONS", to: "0"),
        .define("VMA_DYNAMIC_VULKAN_FUNCTIONS", to: "1"),
        .unsafeFlags(["-I\(openblas)/include"]),
    ]

    linkerSettings = [
        .linkedLibrary("vulkan", .when(platforms: [.android])),
        .linkedLibrary("log", .when(platforms: [.android])),
        .unsafeFlags(["-L\(openblas)/lib"]),
        .linkedLibrary("openblas"),
    ]

    mlxSwiftExcludes = [
        "GPU+Metal.swift",
        "GPU+CUDA.swift",
        "GPU+DirectX.swift",
        "MLXArray+Metal.swift",
    ]
} else {
    #if os(Linux)
    if Context.environment["SPM_CUDA"] != "0" {
        // Linux with CUDA

        platformExcludes =
            [
                "framework",
                "include-framework",
                "metal-cpp",

                "mlx/mlx/backend/no_gpu",
                "mlx/mlx/backend/cuda/no_cuda.cpp",
                "mlx/mlx/backend/cuda/quantized/no_qqmm_impl.cpp",
                "mlx/mlx/backend/cuda/gemms/cublas_gemm_batched_12_0.cpp",
                "mlx/mlx/backend/no_cpu",  // Exclude no_cpu backend on Linux, use cpu instead
                "mlx/mlx/backend/cpu/gemms/bnns.cpp",  // macOS Accelerate version
                "mlx-conditional",
                "mlx-c/mlx/c/metal.cpp",

                "mlx/mlx/backend/cuda/delayload.cpp",  // For Windows
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90_m128_n16_m1.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmv.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90_m128_n32_m1.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90.cuh",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90_m128_n64_m2.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm.h",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90_m128_n256_m2.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/qmm_impl_sm90_m128_n128_m2.cu",
                "mlx/mlx/backend/cuda/quantized/qmm/fp_qmv.cu",
            ] + noMetalCmlxExcludes + noVulkanCmlxExcludes + noDX12CmlxExcludes

        cxxSettings = [
            .unsafeFlags(["-I/usr/local/cuda/include"]),
            .unsafeFlags(["-I/usr/local/cuda/include/cccl"]),
            .define("MLX_CCCL_DIR", to: "\"/usr/local/cuda/include/cccl\""),
        ]

        linkerSettings = [
            .linkedLibrary("gfortran", .when(platforms: [.linux])),
            .linkedLibrary("blas", .when(platforms: [.linux])),
            .linkedLibrary("lapack", .when(platforms: [.linux])),
            .linkedLibrary("openblas", .when(platforms: [.linux])),
            .unsafeFlags(["-L/usr/local/cuda/lib64"]),
            .unsafeFlags(["-L/usr/local/cuda/lib64/stubs"]),
            .linkedLibrary("cudnn"),
            .linkedLibrary("cublas"),
            .linkedLibrary("cublasLt"),
            .linkedLibrary("nvrtc"),
            .linkedLibrary("cudart"),
            .linkedLibrary("cuda"),
        ]

        mlxSwiftExcludes = [
            "GPU+Metal.swift",
            "GPU+Vulkan.swift",
            "GPU+DirectX.swift",
            "MLXArray+Metal.swift",
        ]
    } else {
        // Linux without CUDA (CPU only)

        platformExcludes =
            [
                "framework",
                "include-framework",
                "metal-cpp",

                "mlx/mlx/backend/gpu",  // Exclude GPU backend on Linux, use no_gpu instead
                "mlx/mlx/backend/no_cpu",  // Exclude no_cpu backend on Linux, use cpu instead
                "mlx/mlx/backend/cpu/gemms/bnns.cpp",  // macOS Accelerate version
                "mlx-conditional",
                "mlx-c/mlx/c/metal.cpp",

                "mlx-c/mlx/c/fast.cpp",  // Exclude on Linux - calls metal_kernel unconditionally

            ] + noMetalCmlxExcludes + noCudaCmlxExcludes + noVulkanCmlxExcludes
            + noDX12CmlxExcludes

        cxxSettings = []

        linkerSettings = [
            .linkedLibrary("gfortran", .when(platforms: [.linux])),
            .linkedLibrary("blas", .when(platforms: [.linux])),
            .linkedLibrary("lapack", .when(platforms: [.linux])),
            .linkedLibrary("openblas", .when(platforms: [.linux])),
        ]

        mlxSwiftExcludes = [
            "GPU+Metal.swift",
            "GPU+CUDA.swift",
            "GPU+Vulkan.swift",
            "GPU+DirectX.swift",
            "MLXArray+Metal.swift",
            "MLXFast.swift",
            "MLXFastKernel.swift",
        ]
    }
    #else
    // Apple's platforms with Metal

    platformExcludes =
        [
            "mlx/mlx/backend/cpu/compiled.cpp",
            "mlx/mlx/backend/cpu/jit_compiler.cpp",

            // opt-out of these backends (using metal)
            "mlx/mlx/backend/no_gpu",
            "mlx/mlx/backend/no_cpu",
            "mlx/mlx/backend/metal/no_metal.cpp",

            // bnns instead of simd (accelerate)
            "mlx/mlx/backend/cpu/gemms/simd_fp16.cpp",
            "mlx/mlx/backend/cpu/gemms/simd_bf16.cpp",
        ] + noCudaCmlxExcludes + noVulkanCmlxExcludes + noDX12CmlxExcludes

    cxxSettings = [
        .headerSearchPath("metal-cpp"),

        .define("MLX_USE_ACCELERATE"),
        .define("ACCELERATE_NEW_LAPACK"),
        .define("_METAL_"),
        .define("SWIFTPM_BUNDLE", to: "\"mlx-swift_Cmlx\""),
        .define("METAL_PATH", to: "\"default.metallib\""),
    ]

    linkerSettings = [
        .linkedFramework("Foundation"),
        .linkedFramework("Metal"),
        .linkedFramework("Accelerate"),
    ]

    mlxSwiftExcludes = [
        "GPU+CUDA.swift",
        "GPU+Vulkan.swift",
        "GPU+DirectX.swift",
    ]
    #endif
}

let cmlx = Target.target(
    name: "Cmlx",
    path: "Source/Cmlx",
    exclude: platformExcludes + [
        // vendor docs
        "vendor-README.md",

        // example code + mlx-c distributed
        "mlx-c/examples",
        "mlx-c/mlx/c/distributed.cpp",
        "mlx-c/mlx/c/gguf.cpp",
        "mlx-c/mlx/c/distributed_group.cpp",

        // vendored library, include header only
        "json",

        // vendored library
        "fmt/test",
        "fmt/doc",
        "fmt/support",
        "fmt/src/os.cc",
        "fmt/src/fmt.cc",

        // mlx files that are not part of the build
        "mlx/ACKNOWLEDGMENTS.md",
        "mlx/CMakeLists.txt",
        "mlx/CODE_OF_CONDUCT.md",
        "mlx/CONTRIBUTING.md",
        "mlx/LICENSE",
        "mlx/MANIFEST.in",
        "mlx/README.md",
        "mlx/benchmarks",
        "mlx/cmake",
        "mlx/docs",
        "mlx/examples",
        "mlx/mlx.pc.in",
        "mlx/pyproject.toml",
        "mlx/python",
        "mlx/setup.py",
        "mlx/tests",

        // build variants (we are opting _out_ of these)
        "mlx/mlx/io/no_safetensors.cpp",
        "mlx/mlx/io/gguf.cpp",
        "mlx/mlx/io/gguf_quants.cpp",

        // see PrepareMetalShaders -- don't build the kernels in place
        "mlx/mlx/backend/metal/kernels",
        "mlx/mlx/backend/metal/nojit_kernels.cpp",

        // do not build distributed support (yet)
        "mlx/mlx/distributed/mpi/mpi.cpp",
        "mlx/mlx/distributed/ring/ring.cpp",
        "mlx/mlx/distributed/nccl/nccl.cpp",
        "mlx/mlx/distributed/nccl/nccl_stub",
        "mlx/mlx/distributed/jaccl/jaccl.cpp",
        "mlx/mlx/distributed/jaccl/lib",
        "mlx/mlx/distributed/jaccl/mesh.cpp",
        "mlx/mlx/distributed/jaccl/ring.cpp",
        "mlx/mlx/distributed/jaccl/utils.cpp",
    ],
    cSettings: [
        .headerSearchPath("mlx"),
        .headerSearchPath("mlx-c"),
        .headerSearchPath("mlx-generated/cuda"),
    ],
    cxxSettings: cxxSettings + [
        .headerSearchPath("mlx"),
        .headerSearchPath("mlx-c"),
        .headerSearchPath("json/single_include/nlohmann"),
        .headerSearchPath("fmt/include"),
        .define("MLX_VERSION", to: "\"0.31.1\""),
    ],
    linkerSettings: linkerSettings,
    plugins: [
        .plugin(name: "CudaBuild")
    ],
)

let package = Package(
    name: "mlx-swift",

    platforms: [
        .macOS("14.0"),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
    ],

    products: [
        // main targets
        .library(name: "MLX", targets: ["MLX"]),
        .library(name: "MLXRandom", targets: ["MLXRandom"]),
        .library(name: "MLXNN", targets: ["MLXNN"]),
        .library(name: "MLXOptimizers", targets: ["MLXOptimizers"]),
        .library(name: "MLXFFT", targets: ["MLXFFT"]),
        .library(name: "MLXLinalg", targets: ["MLXLinalg"]),
        .library(name: "MLXFast", targets: ["MLXFast"]),
    ],
    dependencies: [
        // for Complex type
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        cmlx,
        .testTarget(
            name: "CmlxTests",
            dependencies: ["Cmlx"]
        ),

        .target(
            name: "MLX",
            dependencies: [
                "Cmlx",
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            exclude: mlxSwiftExcludes,
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXRandom",
            dependencies: ["MLX"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXFast",
            dependencies: ["MLX", "Cmlx"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXNN",
            dependencies: ["MLX"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXOptimizers",
            dependencies: ["MLX", "MLXNN"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXFFT",
            dependencies: ["MLX"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "MLXLinalg",
            dependencies: ["MLX"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),

        .testTarget(
            name: "MLXTests",
            dependencies: [
                "MLX", "MLXNN", "MLXOptimizers",
            ]
        ),

        // ------
        // Example programs

        .executableTarget(
            name: "Example1",
            dependencies: ["MLX"],
            path: "Source/Examples",
            sources: ["Example1.swift"]
        ),
        .executableTarget(
            name: "Tutorial",
            dependencies: ["MLX"],
            path: "Source/Examples",
            sources: ["Tutorial.swift"]
        ),
        .executableTarget(
            name: "CustomFunctionExample",
            dependencies: ["MLX"],
            path: "Source/Examples",
            sources: ["CustomFunctionExample.swift"]
        ),
        .executableTarget(
            name: "CustomFunctionExampleSimple",
            dependencies: ["MLX"],
            path: "Source/Examples",
            sources: ["CustomFunctionExampleSimple.swift"]
        ),
        .executableTarget(
            name: "encuda",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Source/Encuda",
        ),
        .plugin(
            name: "CudaBuild",
            capability: .buildTool(),
            dependencies: [
                .target(name: "encuda")
            ],
        ),
    ],
    cxxLanguageStandard: .gnucxx20
)

if Context.environment["MLX_SWIFT_BUILD_DOC"] == "1"
    || Context.environment["SPI_GENERATE_DOCS"] == "1"
{
    // docc builder
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    )
}

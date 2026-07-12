// Copyright © 2026 Apple Inc.

// On Apple platforms Darwin provides Swift overloads of the libm functions
// for `Float` (sqrt, log, exp, ...). The Android/Linux C modules only expose
// the C-named variants (logf, expf, ...), so provide the Swift-styled
// overloads the rest of MLXNN uses.
#if os(Android) || os(Linux)
    #if os(Android)
        import Android
    #else
        import Glibc
    #endif

    @inlinable func sqrt(_ x: Float) -> Float { x.squareRoot() }
    @inlinable func log(_ x: Float) -> Float { logf(x) }
    @inlinable func log2(_ x: Float) -> Float { log2f(x) }
    @inlinable func log10(_ x: Float) -> Float { log10f(x) }
    @inlinable func exp(_ x: Float) -> Float { expf(x) }
    @inlinable func pow(_ x: Float, _ y: Float) -> Float { powf(x, y) }
    @inlinable func sin(_ x: Float) -> Float { sinf(x) }
    @inlinable func cos(_ x: Float) -> Float { cosf(x) }
    @inlinable func tan(_ x: Float) -> Float { tanf(x) }
    @inlinable func tanh(_ x: Float) -> Float { tanhf(x) }
    @inlinable func atan2(_ y: Float, _ x: Float) -> Float { atan2f(y, x) }
    @inlinable func floor(_ x: Float) -> Float { x.rounded(.down) }
    @inlinable func ceil(_ x: Float) -> Float { x.rounded(.up) }
    @inlinable func round(_ x: Float) -> Float { x.rounded(.toNearestOrAwayFromZero) }
    @inlinable func fmod(_ x: Float, _ y: Float) -> Float { x.truncatingRemainder(dividingBy: y) }
#endif

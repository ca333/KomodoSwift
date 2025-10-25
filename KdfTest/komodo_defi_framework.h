// This file exposes the raw C functions that are compiled into the static library
// `libkdf.a` (a.k.a. mm2) for iOS.  Including this header in a bridging
// header allows Swift code to call into the Rust core.

// NOTE: Only the functions that we actually need for this demo are
// uncommented below.  The rest remain commented to reflect the upstream
// header.  To learn more about these functions please refer to the
// official Komodo DeFi Framework documentation.

// Guard against multiple inclusion
#ifndef KOMODO_DEFI_FRAMEWORK_H
#define KOMODO_DEFI_FRAMEWORK_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

/// A callback used by mm2 for delivering log lines.  It receives a
/// null‑terminated UTF‑8 string and must not retain the pointer.  On iOS
/// we translate this into a Swift closure via an `@convention(c)` function.
typedef void (*LogCallback)(const char *line);

/// Starts mm2 in a detached singleton thread.  The `conf` argument must be
/// a valid JSON string with the configuration parameters expected by mm2
/// (see `KdfStartupConfig.encodeStartParams` in the Flutter SDK for an
/// example).  `log_cb` is an optional log callback; pass `NULL` to disable
/// log forwarding.  Returns `0` on success or a non‑zero error code on
/// failure.
FFI_PLUGIN_EXPORT int8_t mm2_main(const char *conf, LogCallback log_cb);

/// Checks whether the mm2 singleton thread is running.  The return value
/// corresponds to the following states:
///   0 – not running
///   1 – running, but no context yet
///   2 – context created, but the RPC server is not yet ready
///   3 – RPC server is up and ready to accept JSON‑RPC requests
FFI_PLUGIN_EXPORT int8_t mm2_main_status(void);

/// Stops the mm2 instance and resets static variables.  Returns `0` on
/// success.
FFI_PLUGIN_EXPORT int8_t mm2_stop(void);

// The following functions are present in the upstream header but are
// commented out here because the HTTP JSON‑RPC interface is used to
// retrieve the version string.  If you wish to call RPC methods without
// going through the HTTP stack, you can uncomment these declarations and
// link against a library that exports them.
// FFI_PLUGIN_EXPORT const char *mm2_version(void);
// FFI_PLUGIN_EXPORT const char *mm2_rpc(const char *request);
// FFI_PLUGIN_EXPORT void mm2_rpc_free(char *response);

#endif // KOMODO_DEFI_FRAMEWORK_H
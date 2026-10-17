{ pkgs, lib, config, inputs, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  # Native libraries the Bevy stack (wgpu / winit / cpal / gilrs) links against.
  linuxLibs = with pkgs; [
    alsa-lib          # audio output (cpal / rodio)
    udev              # device/gamepad input
    libGL             # OpenGL loader
    vulkan-loader     # wgpu Vulkan backend
    libxkbcommon      # keyboard (X11 + Wayland)
    libx11
    libxcursor
    libxi
    libxrandr
    wayland
  ];
in
{
  # ---------------------------------------------------------------- Rust
  languages.rust = {
    enable = true;
    # "nixpkgs" cannot cross-compile, so use rust-overlay's stable channel to
    # get the wasm32 target alongside the native one.
    channel = "stable";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
    # Browser build target.
    targets = [ "wasm32-unknown-unknown" ];
  };

  # ------------------------------------------------------------ packages
  packages = with pkgs; [
    trunk              # wasm dev server + bundler
    binaryen           # provides wasm-opt
    pkg-config
  ] ++ lib.optionals isLinux (with pkgs; [
    clang
    lld
  ] ++ linuxLibs);

  # --------------------------------------------------------- environment
  env = {
    RUST_BACKTRACE = "1";
    # NOTE: do NOT set TRUNK_TOOLS_WASM_OPT here. In Trunk that variable is the
    # *version* to download (e.g. "version_132"), not a path. Pointing it at a Nix
    # store path makes Trunk treat the path as a version, mismatch the detected
    # system build, and try to download it. `binaryen` is in `packages` below, so
    # `wasm-opt` is on PATH and Trunk auto-detects it. wasm-bindgen is likewise
    # left to Trunk so its version matches the `wasm-bindgen` crate in Cargo.lock.
  } // lib.optionalAttrs isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath linuxLibs;
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/etc/X11/xkb";
  };

  # ------------------------------------------------------------ scripts
  scripts = {
    dev = {
      description = "Run natively with Bevy as a dylib (fast relinks)";
      exec = "cargo dev";
    };
    dev-static = {
      description = "Run natively with Bevy statically linked (fallback)";
      exec = "cargo run";
    };
    web = {
      description = "Run in the browser with hot reload (opens via Trunk.toml)";
      exec = "trunk serve";
    };
    web-build = {
      description = "Build the production wasm bundle into ./dist";
      # `--release` enables Trunk's release pipeline (wasm-opt); `--cargo-profile`
      # selects the optimized [profile.wasm-release] instead of plain `release`.
      exec = "trunk build --release --cargo-profile wasm-release";
    };
  };

  enterShell = ''
    echo "pirate-escape  ·  $(cargo --version)"
    echo "  dev        -> cargo dev                       (native, dynamic-linking)"
    echo "  dev-static -> cargo run                       (native, static fallback)"
    echo "  web        -> trunk serve                     (browser)"
    echo "  web-build  -> trunk build --release --cargo-profile wasm-release"
  '';

  # ----------------------------------------------------------- git hooks
  git-hooks.hooks = {
    rustfmt.enable = true;
    # clippy.enable = true; # uncomment to gate commits on clippy
  };
}

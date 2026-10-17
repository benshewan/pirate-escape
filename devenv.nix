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
    wasm-bindgen-cli   # JS glue (trunk can also fetch a matching version)
    binaryen           # provides wasm-opt
    pkg-config
  ] ++ lib.optionals isLinux (with pkgs; [
    clang
    lld
  ] ++ linuxLibs);

  # --------------------------------------------------------- environment
  env = {
    RUST_BACKTRACE = "1";
    # wasm-opt ships in binaryen; pin the Nix build so trunk doesn't try to run
    # its glibc-linked download on NixOS. wasm-bindgen is left to trunk so its
    # version always matches the `wasm-bindgen` crate in Cargo.lock.
    TRUNK_TOOLS_WASM_OPT = "${pkgs.binaryen}/bin/wasm-opt";
  } // lib.optionalAttrs isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath linuxLibs;
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/etc/X11/xkb";
  };

  # ------------------------------------------------------------ scripts
  scripts = {
    dev = {
      description = "Run the game natively";
      exec = "cargo run";
    };
    web = {
      description = "Run in the browser with hot reload";
      exec = "trunk serve --open";
    };
    web-build = {
      description = "Build the production wasm bundle into ./dist";
      exec = "trunk build --release";
    };
  };

  enterShell = ''
    echo "pirate-escape  ·  $(cargo --version)"
    echo "  dev        -> cargo run            (native)"
    echo "  web        -> trunk serve --open   (browser)"
    echo "  web-build  -> trunk build --release"
  '';

  # ----------------------------------------------------------- git hooks
  git-hooks.hooks = {
    rustfmt.enable = true;
    # clippy.enable = true; # uncomment to gate commits on clippy
  };
}

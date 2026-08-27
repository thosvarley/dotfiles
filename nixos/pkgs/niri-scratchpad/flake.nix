{
  description = "niri-scratchpad: dynamic & static scratchpad management for niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Pinned to a specific commit of argosnothing/niri-scratchpad-rs.
        # Built here with this system's own rustc/cargo instead of upstream's
        # own flake.nix, which pulls a separate nixos-unstable + rust-overlay
        # beta toolchain just for one small binary.
        src = pkgs.fetchFromGitHub {
          owner = "argosnothing";
          repo = "niri-scratchpad-rs";
          rev = "c78d735267e30e3529c83b2fb3123c49ac4e8d95";
          hash = "sha256-3fE7RVQiZaCXyULb7GGtynvMjwkueSfVK5gbo44yMZ4=";
        };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "niri-scratchpad";
          version = "2.0.0";

          inherit src;

          cargoLock.lockFile = "${src}/Cargo.lock";

          meta = {
            description = "Dynamic & static scratchpad management for niri";
            mainProgram = "niri-scratchpad";
          };
        };
      }
    );
}

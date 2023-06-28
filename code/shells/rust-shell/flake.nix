{
  description = "Rust Shell";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }: let
     system = "x86_64-linux";
     pkgs = import nixpkgs {
      inherit system;
      overlays = [rust-overlay.overlays.default];
    };
    toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;
  in {
        devShells.${system}.default = pkgs.mkShell {
          packages = [
            toolchain
            
            # We want the unwrapped version, "rust-analyzer" (wrapped) comes with nixpkgs' toolchain
            pkgs.rust-analyzer-unwrapped
          ];
         
          
          RUST_BACKTRACE = 1;
          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

          shellHook = ''
            alias ls=ls -ltra
          '';
        };
      };
}


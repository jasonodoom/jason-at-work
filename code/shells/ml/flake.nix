{
  description = "A Python 3.9 environment with wide IPython support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShells.${system}.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ffmpeg
            python39
            python39Packages.ipython
            python39Packages.pip
            python39Packages.numpy
            python39Packages.pytorch
            python39Packages.virtualenv
          ];
        };
      }
    );
}


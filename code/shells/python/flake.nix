{
  description = "Nix flake for Python related stuff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; 
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      ps = pkgs.python311Packages;
    in {
      packages.default = pkgs.mkShell {
        buildInputs = [
          pkgs.pre-commit                 
          ps.pre-commit-hooks              
          ps.flake8
          ps.ipython
          ps.semver
          ps.setuptools
          ps.wheel
          ps.docopt
          ps.urllib3
          ps.pyyaml
          ps.packaging
          ps.boto3
        ];
      };
    }
  );
}


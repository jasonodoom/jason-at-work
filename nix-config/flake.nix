{
  description = "jason-at-work Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      packages = {
        default = pkgs.buildEnv {
          name = "jason-at-work-env";
          paths = with pkgs; [
            awscli2
            bash-completion
            coreutils-full
            direnv
            tree
            wget
            krb5
            p11-kit
            openssh
            gnupg
            pinentry-curses
            yubikey-personalization
            yubikey-manager
            pre-commit
            git-interactive-rebase-tool
            gh
            shfmt
            shellcheck
            vim
            tmux
            ansible
            ansible-lint
            pass
            go
            nodejs
          ];
        };
      };

      apps = {
        default = {
          type = "app";
          program = "${pkgs.bash}/bin/bash";
        };
      };
    });
}

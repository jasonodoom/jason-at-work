{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.awscli2
      pkgs.bash-completion
      pkgs.coreutils-full # For shred and more
      pkgs.direnv
      pkgs.tree
      pkgs.wget
      pkgs.krb5
      pkgs.p11-kit
      pkgs.openssh
      pkgs.gnupg
      pkgs.pinentry-curses
      pkgs.yubikey-personalization 
      pkgs.yubikey-manager
      pkgs.pre-commit
      pkgs.git-interactive-rebase-tool
      pkgs.gh
      pkgs.shfmt
      pkgs.shellcheck
      pkgs.vim
      pkgs.tmux
      pkgs.vagrant
      pkgs.terraform
      pkgs.packer
      pkgs.ansible
      pkgs.ansible-lint
      pkgs.pass
      pkgs.go
      pkgs.nodejs
      pkgs.chromedriver
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  #programs.bash.enable = true;
  #programs.bash.enableCompletion = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

# jason-at-work
Dotfiles mainly for my work mbp.

###Notes:
```bash
nix-channel --add https://channels.nixos.org/nixos-23.05 nixpkgs
nix-channel --update
nix-env --upgrade
```

####Verify:
```bash
 nix-shell -p nix-info --run "nix-info -m"
```

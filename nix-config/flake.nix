{
  description = "jason-at-work Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = false;
            allowUnsupportedSystem = false;
          };
          overlays = [ self.overlays.default ];
        };

        packageSets = {
          # Core system utilities
          coreUtils = with pkgs; [
            coreutils-full
            bash-completion
            direnv
            tree
            wget
            openssh
            gnupg
            pinentry-curses
            vim
            tmux
            jq
          ];

          # Cloud and infrastructure tools
          cloudTools = with pkgs; [
            awscli2
            eksctl
            kustomize
            kubectl
            k9s
            helm
            ansible
            ansible-lint
          ];

          # Development tools
          devTools = with pkgs; [
            git-interactive-rebase-tool
            gh
            shfmt
            shellcheck
            pre-commit
            go
            nodejs_20
            yarn
            nodePackages.elasticdump
            python3
            poetry
          ];

          # Security and authentication tools
          securityTools = with pkgs; [
            krb5
            p11-kit
            yubikey-personalization
            yubikey-manager
            pass
          ];

          # Optional packages that may not exist in all nixpkgs versions
          optionalTools =
            with pkgs;
            [
              # Add packages with error handling
            ]
            ++ (pkgs.lib.optionals (pkgs ? claude-code) [
              # Use our specific version of claude-code if available
              pkgs.claude-code
            ]);
        };

        # Flatten all package sets for the main environment
        allPackages =
          with packageSets;
          coreUtils ++ cloudTools ++ devTools ++ securityTools ++ optionalTools;

        # Main development environment
        developmentEnvironment = pkgs.buildEnv {
          name = "jason-at-work-env";
          paths = allPackages;

          # Handle package conflicts gracefully
          ignoreCollisions = false;

          # Add useful outputs
          extraOutputsToInstall = [
            "dev"
            "out"
          ];

          postBuild = ''
            # Create an environment setup script
            mkdir -p $out/bin
            cat > $out/bin/setup-env << 'EOF'
            #!/usr/bin/env bash
            echo "Jason's Development Environment"
            echo "Total packages: ${toString (builtins.length allPackages)}"
            echo ""
            echo "Available tool categories:"
            echo "Core Utils: ${toString (builtins.length packageSets.coreUtils)} tools"
            echo "Cloud Tools: ${toString (builtins.length packageSets.cloudTools)} tools"
            echo "Dev Tools: ${toString (builtins.length packageSets.devTools)} tools"
            echo "Security: ${toString (builtins.length packageSets.securityTools)} tools"
            echo ""
            echo "Quick aliases:"
            echo "  ll='ls -la'"
            echo "  k='kubectl'"
            echo "  py='python3'"
            echo ""
            echo "Environment ready!"
            EOF
            chmod +x $out/bin/setup-env
          '';
        };

      in
      {
        packages = {
          default = developmentEnvironment;

          # Individual package sets for selective installation
          core = pkgs.buildEnv {
            name = "jason-core-utils";
            paths = packageSets.coreUtils;
          };

          cloud = pkgs.buildEnv {
            name = "jason-cloud-tools";
            paths = packageSets.cloudTools;
          };

          dev = pkgs.buildEnv {
            name = "jason-dev-tools";
            paths = packageSets.devTools;
          };

          security = pkgs.buildEnv {
            name = "jason-security-tools";
            paths = packageSets.securityTools;
          };
        };

        # Application shortcuts
        apps = {
          default = {
            type = "app";
            program = "${pkgs.bash}/bin/bash";
          };

          setup-env = {
            type = "app";
            program = "${developmentEnvironment}/bin/setup-env";
          };

          # Direct access to key tools
          aws = {
            type = "app";
            program = "${pkgs.awscli2}/bin/aws";
          };

          k9s = {
            type = "app";
            program = "${pkgs.k9s}/bin/k9s";
          };
        };

        # Development shells for different use cases
        devShells = {
          # Default full-featured development shell
          default = pkgs.mkShell {
            name = "jason-dev-shell";
            packages = allPackages;

            shellHook = ''
              echo "Jason's Development Environment"
              echo "Loaded ${toString (builtins.length allPackages)} packages"

              # Set up helpful aliases
              alias ll='ls -la'
              alias k='kubectl'
              alias py='python3'
              alias tf='terraform'

              # Configure direnv if available
              if command -v direnv >/dev/null 2>&1; then
                eval "$(direnv hook bash)"
                echo "direnv enabled"
              fi

              # Validate key tools
              echo "Checking key tools..."
              for tool in aws python3 go node; do
                if command -v $tool >/dev/null 2>&1; then
                  echo "  $tool available"
                else
                  echo "  $tool missing"
                fi
              done

              echo ""
              echo "Run 'setup-env' for detailed information"
              echo "Happy coding!"
            '';

            # Environment variables
            BUILD_ENV = "development";
            DEVELOPMENT_SHELL = "true";
            EDITOR = "vim";
            AWS_PAGER = "";
          };

          # Minimal shell for CI/CD
          ci = pkgs.mkShell {
            name = "jason-ci-shell";
            packages = with packageSets; coreUtils ++ cloudTools ++ devTools;

            shellHook = ''
              echo "CI/CD Environment"
              export AWS_PAGER=""
              export TERM=xterm-256color
            '';
          };

          # Security-focused shell
          security = pkgs.mkShell {
            name = "jason-security-shell";
            packages = with packageSets; coreUtils ++ securityTools;

            shellHook = ''
              echo "Security Tools Environment"
              echo "Available: yubikey-manager, pass, gnupg, krb5"
            '';
          };
        };

        # Quality assurance checks
        checks = {
          # Build verification
          environment-builds = developmentEnvironment;

          # Tool availability check
          tools-available = pkgs.runCommand "tools-check" { } ''
            echo "Verifying essential tools..."

            # Check for critical tools
            essential_tools=(
              "${pkgs.awscli2}/bin/aws"
              "${pkgs.python3}/bin/python3"
              "${pkgs.go}/bin/go"
              "${pkgs.git-interactive-rebase-tool}/bin/git-interactive-rebase-tool"
            )

            for tool in "''${essential_tools[@]}"; do
              if [[ -x "$tool" ]]; then
                echo "$tool exists and is executable"
              else
                echo "$tool missing or not executable"
                exit 1
              fi
            done

            echo "All essential tools verified"
            touch $out
          '';

          # Package count validation
          package-count = pkgs.runCommand "package-count-check" { } ''
            expected_min=25
            actual=${toString (builtins.length allPackages)}

            if [[ $actual -ge $expected_min ]]; then
              echo "Package count ($actual) meets minimum ($expected_min)"
              touch $out
            else
              echo "Package count ($actual) below minimum ($expected_min)"
              exit 1
            fi
          '';
        };

        # Code formatting
        formatter = pkgs.nixfmt-rfc-style;
      }
    ))
    // {
      # System-independent outputs
      overlays = {
        default = final: prev: {
          # Specify claude-code version to use
          claude-code =
            if (prev ? claude-code) then
              prev.claude-code.overrideAttrs (oldAttrs: rec {
                version = "2.0.5";
                src = prev.fetchurl {
                  url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
                  hash = "sha256-vT+Csqi3vtAbQam6p2qzefBycFDkUO+k5EdHHcCPT2k=";
                };
                npmDepsHash = "sha256-0x3f8c4xx7hlqffjy2qyzpic55rjj5r8i2svkjjlqdl0kf3si6f3";
              })
            else
              # Fallback if claude-code doesn't exist
              prev.writeShellScriptBin "claude-code" ''
                echo "claude-code not available"
                exit 1
              '';
        };
      };

      nixConfig = {
        builders-use-substitutes = true;
        extra-substituters = [
          "https://cache.nixos.org/"
        ];
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
}

{
  description = "A flake with pre-commit hooks";

  inputs = {
    flake-modules-core.url = "github:hercules-ci/flake-modules-core";
    flake-modules-core.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks-nix.url = "github:hercules-ci/pre-commit-hooks.nix/flakeModule";
    pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, flake-modules-core, ... }:
    (flake-modules-core.lib.evalFlakeModule
      { inherit self; }
      {
        imports = [
          inputs.pre-commit-hooks-nix.flakeModule
        ];
        systems = [ "x86_64-linux" "aarch64-darwin" ];
        perSystem = system: { config, self', inputs', ... }: {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          packages.hello = inputs'.nixpkgs.legacyPackages.hello;
          pre-commit.pkgs = inputs'.nixpkgs.legacyPackages;
          pre-commit.settings.hooks.nixpkgs-fmt.enable = true;
          devShell = inputs'.nixpkgs.legacyPackages.mkShell {
            shellHook = ''
              ${config.pre-commit.installationScript}
              echo 1>&2 "Welcome to the development shell!"
            '';
          };
        };
        flake = {
          # The usual flake attributes can be defined here, including system-
          # agnostic ones like nixosModule and system-enumerating ones, although
          # those are more easily expressed in perSystem.

        };
      }
    ).config.flake;
}

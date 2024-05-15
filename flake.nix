{
  description = "Seamless integration of https://pre-commit.com git hooks with Nix.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, gitignore, nixpkgs-stable, ... }:
    let
      lib = nixpkgs.lib;
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      depsFor = lib.genAttrs defaultSystems (system: {
        pkgs = nixpkgs.legacyPackages.${system};
        exposed = import ./nix { inherit nixpkgs system; gitignore-nix-src = gitignore; isFlakes = true; };
        exposed-stable = import ./nix { nixpkgs = nixpkgs-stable; inherit system; gitignore-nix-src = gitignore; isFlakes = true; };
      });
      forAllSystems = fn: lib.genAttrs defaultSystems (system: fn depsFor.${system});
    in
    {
      flakeModule = ./flake-module.nix;

      templates.default = {
        path = ./template;
        description = ''
          A template with flake-parts and nixpkgs-fmt.
        '';
      };

      packages = forAllSystems ({ exposed, ... }: exposed.packages // {
        default = exposed.packages.pre-commit;
      });

      devShells = forAllSystems ({ pkgs, exposed, ... }: {
        default = pkgs.mkShellNoCC {
          inherit (exposed.checks.pre-commit-check) shellHook;
        };
      });

      checks = forAllSystems ({ exposed, exposed-stable, ... }:
        lib.filterAttrs (k: v: v != null)
          (exposed.checks
            // (lib.mapAttrs' (name: value: lib.nameValuePair "stable-${name}" value)
            exposed-stable.checks)));

      lib = forAllSystems ({ exposed, ... }: { inherit (exposed) run; });
    };
}

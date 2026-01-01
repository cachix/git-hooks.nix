{
  description = "Seamless integration of https://pre-commit.com git hooks with Nix.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-compat = {
    url = "github:NixOS/flake-compat";
    flake = false;
  };
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, gitignore, ... }:
    let
      lib = nixpkgs.lib;
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      genDepsFor = fn: system:
        let
          args = {
            pkgs = nixpkgs.legacyPackages.${system};
            exposed = import ./nix { inherit nixpkgs system; gitignore-nix-src = gitignore; isFlakes = true; };
          };
        in
        fn args;
      forAllSystems = fn: lib.genAttrs defaultSystems (genDepsFor fn);
    in
    {
      flakeModule = ./flake-module.nix;

      templates.default = {
        path = ./template;
        description = ''
          A template with flake-parts and nixpkgs-fmt.
        '';
      };

      # The set of tools exposed by git-hooks.
      # We use legacyPackages because not all tools are derivations that evaluate.
      legacyPackages = forAllSystems ({ pkgs, exposed, ... }: exposed.tools // {
        pre-commit = pkgs.pre-commit;
      });

      # WARN: use `legacyPackages` instead to get error messages for deprecated packages
      #
      # Each entry is guaranteed to be a derivation that evaluates.
      # TODO: this should be deprecated as it exposes a subset of nixpkgs, which is incompatiile with the packages output.
      packages = forAllSystems ({ exposed, ... }: exposed.packages // {
        default = exposed.packages.pre-commit;
      });

      devShells = forAllSystems ({ pkgs, exposed, ... }: {
        default = pkgs.mkShellNoCC {
          inherit (exposed.checks.pre-commit-check) shellHook;
        };
      });

      checks = forAllSystems ({ exposed, ... }: exposed.checks);

      lib = forAllSystems ({ exposed, ... }: { inherit (exposed) run; });

      # TODO: remove and expose a `lib` function is needed
      exposed = forAllSystems ({ exposed, ... }: exposed);
    };
}

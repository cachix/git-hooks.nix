{
  description = "Seamless integration of https://pre-commit.com git hooks with Nix.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, gitignore, nixpkgs-stable, ... }:
    let
      lib = nixpkgs.lib;
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      flakeModule = ./flake-module.nix;

      defaultTemplate = {
        path = ./template;
        description = ''
          A template with flake-parts and nixpkgs-fmt.
        '';
      };
    }
    // flake-utils.lib.eachSystem defaultSystems (system:
      let
        exposed = import ./nix { nixpkgs = nixpkgs; inherit system; gitignore-nix-src = gitignore; isFlakes = true; };
        exposed-stable = import ./nix { nixpkgs = nixpkgs-stable; inherit system; gitignore-nix-src = gitignore; isFlakes = true; };
      in
      {
        packages = exposed.packages;

        defaultPackage = exposed.packages.pre-commit;

        devShell = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (exposed.checks.pre-commit-check) shellHook;
        };

        checks = lib.filterAttrs (k: v: v != null)
          (exposed.checks // exposed-stable.checks);

        lib = { inherit (exposed) run; };
      }
    );
}

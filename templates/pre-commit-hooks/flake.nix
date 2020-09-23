{
  description = "";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-20.03";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix/master";

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem
      (
        system: rec {
          pre-commit-check = pre-commit-hooks.packages.${system}.run {
            src = ./.;
            # If your hooks are intrusive, avoid running on each commit with a default_states like this:
            # default_stages = ["manual" "push"];
            hooks = {
              elm-format.enable = true;
              ormolu.enable = true;
              shellcheck.enable = true;
            };
          };

          devShell =
            nixpkgs.legacyPackages.${system}.mkShell {
              inherit (pre-commit-check) shellHook;
            };
        }
      );
}

{
  description = "Seamless integration of https://pre-commit.com git hooks with Nix.";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
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
        exposed = import ./nix { nixpkgs = nixpkgs; inherit system; gitignore-nix-src = null; isFlakes = true; };
      in
      {
        packages = exposed.packages;

        defaultPackage = exposed.packages.pre-commit;

        checks = exposed.checks;

        lib = { inherit (exposed) run; };
      }
    );
}

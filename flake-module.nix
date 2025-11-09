/*
  A module to import into flakes based on flake-parts.
  Makes integration into a flake easy and tidy.
  See https://flake.parts,
  https://flake.parts/options/pre-commit-hooks-nix
*/

{ lib, self, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, options, pkgs, ... }:
      let cfg = config.pre-commit;
      in
      {
        options = {
          pre-commit = {
            check.enable = mkOption {
              description = ''
                Whether to add a derivation to the flake `checks`.
                It will perform the pre-commit checks in `nix flake check`.

                You can disable this if one of your hooks do not run properly in
                the Nix sandbox; for example because it needs network access.
              '';
              type = types.bool;
              default = true;
            };
            pkgs = mkOption {
              type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
              description = ''
                Nixpkgs to use in the pre-commit [`settings`](#opt-perSystem.pre-commit.settings).
              '';
              default = pkgs;
              defaultText = lib.literalExpression "`pkgs` (module argument)";
            };
            settings = mkOption {
              type = types.submoduleWith {
                modules = [ ./modules/all-modules.nix ];
                specialArgs = { inherit (cfg) pkgs; };
              };
              default = { };
              description = ''
                The git-hooks.nix configuration.
              '';
            };
            shellHook = mkOption {
              type = types.str;
              description = "A shell hook that installs up the git hooks in a development shell.";
              default = cfg.settings.shellHook;
              defaultText = lib.literalExpression "bash statements";
              readOnly = true;
            };
            installationScript = mkOption {
              type = types.str;
              description = "A bash snippet that sets up the git hooks in the current repository.";
              default = cfg.settings.installationScript;
              defaultText = lib.literalExpression "bash statements";
              readOnly = true;
            };
            devShell = mkOption {
              type = types.package;
              description = "A development shell with the git hooks installed and all the packages made available.";
              readOnly = true;
            };
          };
        };
        config = {
          checks = lib.optionalAttrs cfg.check.enable { pre-commit = cfg.settings.run; };
          pre-commit.settings = { pkgs, ... }: {
            rootSrc = self.outPath;
            package = lib.mkDefault pkgs.pre-commit;
            tools = import ./nix/call-tools.nix pkgs;
            hooks.treefmt.package = lib.mkIf (options?treefmt) (lib.mkOverride 900 config.treefmt.build.wrapper);
          };
          pre-commit.devShell = pkgs.mkShell {
            inherit (cfg.settings) shellHook;
            nativeBuildInputs = cfg.settings.enabledPackages;
          };
        };
      });
  };
}

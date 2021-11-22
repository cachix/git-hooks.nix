/*
  A module to import into flakes based on flake-modules-core.
  Makes integration into a flake easy and tidy.
  See https://github.com/hercules-ci/flake-modules-core#readme
*/

{ lib, self, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  config = {
    perSystem = system: { config, self', inputs', ... }:
      let
        cfg = config.pre-commit;
      in
      {
        options = {
          pre-commit = {
            pkgs = mkOption {
              type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
              description = ''
                Nixpkgs to use for pre-commit checking.
              '';
              # Not sure what's the best default:
              #  - pre-commit-hooks-nix.inputs.nixpkgs.legacyPackages.${system}
              #    (could be passed in, making this file a function to a module function)
              #    ci-checked but incompatible with user pkgs unless they use inputs.nixpkgs.follows
              #    awkward if user wants to use an overlay
              #  - config._module.args.pkgs (a default pkgs set by user / some other module)
              #    always compatible with user pkgs, because it is user pkgs
              #    not sure if we want to standardize having a default pkgs
              #  - nothing: keep this as a manual setting.
              #    foolproof but inconvenient.
            };
            settings = mkOption {
              type = types.submoduleWith {
                modules = [ ./modules/all-modules.nix ];
                specialArgs = { inherit (cfg) pkgs; };
              };
              default = { };
            };
            installationScript = mkOption {
              type = types.str;
              description = "A bash fragment that sets up pre-commit.";
              default = cfg.settings.installationScript;
              readOnly = true;
            };
          };
        };
        config = {
          checks.pre-commit = cfg.settings.run;
          pre-commit.settings = { pkgs, ... }: {
            rootSrc = self.outPath;
            package = lib.mkDefault pkgs.pre-commit;
            tools = import ./nix/call-tools.nix pkgs;
          };
        };
      };
  };
}

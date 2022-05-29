/*
  A module to import into flakes based on flake-parts.
  Makes integration into a flake easy and tidy.
  See https://flake.parts
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
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, pkgs, ... }:
      let cfg = config.pre-commit;
      in
      {
        options = {
          pre-commit = {
            pkgs = mkOption {
              type = types.uniq (types.lazyAttrsOf (types.raw or types.unspecified));
              description = ''
                Nixpkgs to use for pre-commit checking.
              '';
              default = pkgs;
              defaultText = lib.literalDocBook "<literal>pkgs</literal> (module argument)";
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
              defaultText = lib.literalDocBook "bash statements";
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
      });
  };
}

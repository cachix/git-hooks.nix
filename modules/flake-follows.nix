{ config, lib, hookModule, ... }:
let
  inherit (config) hooks tools;
  inherit (lib) mkDefault mkOption types;
in
{
  options.hooks.flake-follows = mkOption {
    description = ''
      flake-follows hook.

      Adds missing `follows` declarations to `flake.nix` using `flake-edit follow`.
    '';
    type = types.submodule {
      imports = [ hookModule ];
      options.settings = {
        flake = mkOption {
          type = types.oneOf [ types.str types.path ];
          description = "Path to the flake file to update.";
          default = "flake.nix";
        };

        lockFile = mkOption {
          type = types.oneOf [ types.str types.path ];
          description = "Path to the flake lock file used as input by `flake-edit`.";
          default = "flake.lock";
        };

        noLock = mkOption {
          type = types.bool;
          description = "Whether to pass `--no-lock` to avoid updating the lock file.";
          default = true;
        };
      };
    };
  };

  config.hooks.flake-follows = lib.mapAttrs (_: mkDefault) {
    name = "flake-follows";
    description = "Add missing follows declarations to Nix flakes.";
    package = tools.flake-edit;
    entry =
      let
        flake = lib.escapeShellArg (toString hooks.flake-follows.settings.flake);
        lockFile = lib.escapeShellArg (toString hooks.flake-follows.settings.lockFile);
        noLock = lib.optionalString hooks.flake-follows.settings.noLock "--no-lock";
      in
      "${hooks.flake-follows.package}/bin/flake-edit --flake ${flake} --lock-file ${lockFile} ${noLock} --non-interactive follow";
    files = "^(flake\\.nix|flake\\.lock)$";
    pass_filenames = false;
  };
}

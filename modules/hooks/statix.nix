{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    config =
      mkOption {
        type = types.nullOr types.str;
        description = "Path to statix.toml or its parent directory.";
        default = null;
      };

    format =
      mkOption {
        type = types.enum [ "stderr" "errfmt" "json" ];
        description = "Error Output format.";
        default = "errfmt";
      };

    ignore =
      mkOption {
        type = types.listOf types.str;
        description = "Globs of file patterns to skip.";
        default = [ ];
        example = [ "flake.nix" "_*" ];
      };

    unrestricted =
      mkOption {
        type = types.bool;
        description = "Don't respect .gitignore files.";
        default = false;
        example = true;
      };
  };
}

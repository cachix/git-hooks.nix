{ lib, tools, config, ... }:
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

  config = {
    name = "statix";
    description = "Lints and suggestions for the Nix programming language.";
    package = tools.statix;
    entry =
      let
        inherit (config) package settings;
        mkOptionName = k:
          if builtins.stringLength k == 1
          then "-${k}"
          else "--${k}";
        options = lib.cli.toGNUCommandLineShell
          {
            # instead of repeating the option name for each element,
            # create a single option with a space-separated list of unique values.
            mkList = k: v: if v == [ ] then [ ] else [ (mkOptionName k) ] ++ lib.unique v;
          }
          settings;
      in
      "${package}/bin/statix check ${options}";
    files = "\\.nix$";
    pass_filenames = false;
  };
}

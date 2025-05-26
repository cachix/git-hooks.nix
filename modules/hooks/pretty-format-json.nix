{ lib, config, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    autofix =
      mkOption {
        type = types.bool;
        description = "Automatically format JSON files.";
        default = false;
      };
    indent =
      mkOption {
        type = types.nullOr (types.oneOf [ types.int types.str ]);
        description = "Control the indentation (either a number for a number of spaces or a string of whitespace). Defaults to 2 spaces.";
        default = null;
      };
    no-ensure-ascii =
      mkOption {
        type = types.bool;
        description = "Preserve unicode characters instead of converting to escape sequences.";
        default = false;
      };
    no-sort-keys =
      mkOption {
        type = types.bool;
        description = "When autofixing, retain the original key ordering (instead of sorting the keys).";
        default = false;
      };
    top-keys =
      mkOption {
        type = types.listOf types.str;
        description = "Keys to keep at the top of mappings.";
        default = [ ];
      };
  };

  config = {
    name = "pretty-format-json";
    description = "Pretty format JSON.";
    package = tools.pre-commit-hooks;
    entry =
      let
        binPath = "${config.package}/bin/pretty-format-json";
        cmdArgs = mkCmdArgs (with config.settings; [
          [ autofix "--autofix" ]
          [ (indent != null) "--indent ${toString indent}" ]
          [ no-ensure-ascii "--no-ensure-ascii" ]
          [ no-sort-keys "--no-sort-keys" ]
          [ (top-keys != [ ]) "--top-keys ${lib.strings.concatStringsSep "," top-keys}" ]
        ]);
      in
      "${binPath} ${cmdArgs}";
    types = [ "json" ];
  };
}

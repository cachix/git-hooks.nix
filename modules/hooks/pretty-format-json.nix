{ lib, ... }:
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
}

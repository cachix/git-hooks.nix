{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    width =
      mkOption {
        type = types.nullOr types.int;
        description = "Line width.";
        default = null;
      };
  };
}

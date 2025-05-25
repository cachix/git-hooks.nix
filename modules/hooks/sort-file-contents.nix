{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    ignore-case =
      mkOption {
        type = types.bool;
        description = "Fold lower case to upper case characters.";
        default = false;
      };
    unique =
      mkOption {
        type = types.bool;
        description = "Ensure each line is unique.";
        default = false;
      };
  };
}

{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    simplify = mkOption {
      type = types.bool;
      description = "Simplify the code.";
      default = true;
    };
  };
}

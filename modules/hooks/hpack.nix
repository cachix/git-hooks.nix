{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    silent =
      mkOption {
        type = types.bool;
        description = "Whether generation should be silent.";
        default = false;
      };
  };
}

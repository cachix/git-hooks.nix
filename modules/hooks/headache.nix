{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    header-file = mkOption {
      type = types.str;
      description = "Path to the header file.";
      default = ".header";
    };
  };
}

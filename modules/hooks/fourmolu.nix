{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    defaultExtensions = mkOption {
      type = types.listOf types.str;
      description = "Haskell language extensions to enable.";
      default = [ ];
    };
  };
}

{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    flags = mkOption {
      type = types.str;
      description = "Flags passed to reuse. For available options run 'reuse lint --help'";
      default = "";
      example = "--json";
    };
  };
}

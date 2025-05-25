{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    flags = mkOption {
      type = types.str;
      description = "Flags passed to golines. See all available [here](https://github.com/segmentio/golines?tab=readme-ov-file#options)";
      default = "";
      example = "-m 120";
    };
  };
}

{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    packageOverrides = {
      treefmt = mkOption {
        type = types.package;
        description = "The treefmt package to use";
      };
    };

    settings = {
      fail-on-change = mkOption {
        type = types.bool;
        description = "Fail if some files require re-formatting.";
        default = true;
      };
      no-cache = mkOption {
        type = types.bool;
        description = "Ignore the evaluation cache entirely.";
        default = true;
      };
      formatters = mkOption {
        type = types.listOf types.package;
        description = "The formatter packages configured by treefmt";
        default = [ ];
      };
    };
  };

  config.extraPackages = config.settings.formatters;
}

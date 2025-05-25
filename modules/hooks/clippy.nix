{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    settings = {
      denyWarnings = mkOption {
        type = types.bool;
        description = "Fail when warnings are present";
        default = false;
      };
      offline = mkOption {
        type = types.bool;
        description = "Run clippy offline";
        default = true;
      };
      allFeatures = mkOption {
        type = types.bool;
        description = "Run clippy with --all-features";
        default = false;
      };
      extraArgs = mkOption {
        type = types.str;
        description = "Additional arguments to pass to clippy";
        default = "";
      };
    };

    packageOverrides = {
      cargo = mkOption {
        type = types.package;
        description = "The cargo package to use";
      };
      clippy = mkOption {
        type = types.package;
        description = "The clippy package to use";
      };
    };
  };

  config.extraPackages = [
    config.packageOverrides.cargo
    config.packageOverrides.clippy
  ];
}

{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    auto-promote = mkOption {
      type = types.bool;
      description = "Whether to auto-promote the changes.";
      default = true;
    };

    extraRuntimeInputs = mkOption {
      type = types.listOf types.package;
      description = "Extra runtimeInputs to add to the environment, eg. `ocamlformat`.";
      default = [ ];
    };
  };

  config.extraPackages = config.settings.extraRuntimeInputs;
}

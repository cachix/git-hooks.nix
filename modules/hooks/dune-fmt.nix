{ config, lib, pkgs, tools, ... }:
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

  config = {
    name = "dune-fmt";
    description = "Runs Dune's formatters on the code tree.";
    package = tools.dune-fmt;
    entry =
      let
        auto-promote = if config.settings.auto-promote then "--auto-promote" else "";
        run-dune-fmt = pkgs.writeShellApplication {
          name = "run-dune-fmt";
          runtimeInputs = config.settings.extraRuntimeInputs;
          text = "${config.package}/bin/dune-fmt ${auto-promote}";
        };
      in
      "${run-dune-fmt}/bin/run-dune-fmt";
    pass_filenames = false;
    extraPackages = config.settings.extraRuntimeInputs;
  };
}

{ config, lib, pkgs, tools, mkCmdArgs, ... }:
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

  config =
    let
      inherit (config) packageOverrides settings;
      wrapper =
        pkgs.writeShellApplication {
          name = "treefmt";
          runtimeInputs = [
            packageOverrides.treefmt
          ] ++ settings.formatters;

          text =
            ''
              exec treefmt "$@"
            '';
        };
    in
    {
      name = "treefmt";
      description = "One CLI to format the code tree.";
      types = [ "file" ];
      pass_filenames = true;
      package = wrapper;
      packageOverrides = { inherit (tools) treefmt; };
      entry =
        let
          cmdArgs =
            mkCmdArgs
              (with config.settings; [
                [ fail-on-change "--fail-on-change" ]
                [ no-cache "--no-cache" ]
              ]);
        in
        "${config.package}/bin/treefmt ${cmdArgs}";
      extraPackages = config.settings.formatters;
    };
}

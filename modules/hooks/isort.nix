{ config, lib, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    profile =
      mkOption {
        type = types.enum [ "" "black" "django" "pycharm" "google" "open_stack" "plone" "attrs" "hug" "wemake" "appnexus" ];
        description = "Built-in profiles to allow easy interoperability with common projects and code styles.";
        default = "";
      };
    flags =
      mkOption {
        type = types.str;
        description = "Flags passed to isort. See all available [here](https://pycqa.github.io/isort/docs/configuration/options.html).";
        default = "";
      };
  };

  config = {
    name = "isort";
    description = "A Python utility / library to sort imports.";
    types = [ "file" "python" ];
    package = tools.isort;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (profile != "") " --profile ${profile}" ]
            ]);
      in
      "${config.package}/bin/isort${cmdArgs} ${config.settings.flags}";
  };
}

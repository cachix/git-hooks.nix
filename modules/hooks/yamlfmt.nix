{ lib, config, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath =
      mkOption {
        type = types.str;
        description = "Path to a custom configuration file.";
        # An empty string translates to yamlfmt looking for a configuration file in the
        # following locations (by order of preference):
        # a file named .yamlfmt, yamlfmt.yml, yamlfmt.yaml, .yamlfmt.yaml or .yamlfmt.yml in the current working directory
        # See details [here](https://github.com/google/yamlfmt/blob/main/docs/config-file.md#config-file-discovery)
        default = "";
        example = ".yamlfmt";
      };
    lint-only =
      mkOption {
        type = types.bool;
        description = "Only lint the files, do not format them in place.";
        default = true;
      };
  };

  config = {
    types = [ "file" "yaml" ];
    package = tools.yamlfmt;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              # Exit with non-zero status if the file is not formatted
              [ lint-only "-lint" ]
              # Do not print the diff
              [ lint-only "-quiet" ]
              # See https://github.com/google/yamlfmt/blob/main/docs/config-file.md#config-file-discovery
              [ (configPath != "") "-conf ${configPath}" ]
            ]);
      in
      "${config.package}/bin/yamlfmt ${cmdArgs}";
  };
}

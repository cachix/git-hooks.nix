{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath = mkOption {
      type = types.str;
      description = "Path to the YAML configuration file.";
      # an empty string translates to use default configuration of the
      # underlying ansible-lint binary
      default = "";
    };
    subdir = mkOption {
      type = types.str;
      description = "Path to the Ansible subdirectory.";
      default = "";
    };
  };

  config = {
    package = tools.ansible-lint;
    entry =
      let
        cmdArgs =
          mkCmdArgs [
            [ (config.settings.configPath != "") "-c ${config.settings.configPath}" ]
          ];
      in
      "${config.package}/bin/ansible-lint ${cmdArgs}";
    files = if config.settings.subdir != "" then "${config.settings.subdir}/" else "";
  };
}

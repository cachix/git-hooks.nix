{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
  
  mkCmdArgs = predActionList:
    lib.concatStringsSep
      " "
      (builtins.foldl'
        (acc: entry:
          acc ++ lib.optional (builtins.elemAt entry 0) (builtins.elemAt entry 1))
        [ ]
        predActionList);
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
    name = "ansible-lint";
    description = "Ansible linter";
    package = tools.ansible-lint;
    entry =
      let
        cmdArgs =
          mkCmdArgs [
            [ (config.settings.configPath != "") "-c ${config.settings.configPath}" ]
          ];
      in
      "${tools.ansible-lint}/bin/ansible-lint ${cmdArgs}";
    files = if config.settings.subdir != "" then "${config.settings.subdir}/" else "";
  };
}

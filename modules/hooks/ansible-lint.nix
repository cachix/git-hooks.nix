{ lib, ... }:
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
}

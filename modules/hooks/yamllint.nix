{ lib, tools, config, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    # `list-files` is not useful for a pre-commit hook as it always exits with exit code 0
    # `no-warnings` is not useful for a pre-commit hook as it exits with exit code 2 and the hook
    # therefore fails when warnings level problems are detected but there is no output
    configuration = mkOption {
      type = types.str;
      description = "Multiline-string configuration passed as config file. If set, configuration file set in `yamllint.settings.configPath` gets ignored.";
      default = "";
      example = ''
        ---

        extends: relaxed

        rules:
          indentation: enable
      '';
    };
    configData = mkOption {
      type = types.str;
      description = "Serialized YAML object describing the configuration.";
      default = "";
      example = "{extends: relaxed, rules: {line-length: {max: 120}}}";
    };
    configPath = mkOption {
      type = types.str;
      description = "Path to a custom configuration file.";
      # An empty string translates to yamllint looking for a configuration file in the
      # following locations (by order of preference):
      # a file named .yamllint, .yamllint.yaml or .yamllint.yml in the current working directory
      # a filename referenced by $YAMLLINT_CONFIG_FILE, if set
      # a file named $XDG_CONFIG_HOME/yamllint/config or ~/.config/yamllint/config, if present
      default = "";
    };
    format = mkOption {
      type = types.enum [ "parsable" "standard" "colored" "github" "auto" ];
      description = "Format for parsing output.";
      default = "auto";
    };
    preset = mkOption {
      type = types.enum [ "default" "relaxed" ];
      description = "The configuration preset to use.";
      default = "default";
    };
    strict = mkOption {
      type = types.bool;
      description = "Return non-zero exit code on warnings as well as errors.";
      default = true;
    };
  };

  config = {
    name = "yamllint";
    description = "Linter for YAML files.";
    types = [ "file" "yaml" ];
    package = tools.yamllint;
    entry =
      let
        configFile = builtins.toFile "yamllint.yaml" "${config.settings.configuration}";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              # Priorize multiline configuration over serialized configuration and configuration file
              [ (configuration != "") "--config-file ${configFile}" ]
              [ (configData != "" && configuration == "") "--config-data \"${configData}\"" ]
              [ (configPath != "" && configData == "" && configuration == "" && preset == "default") "--config-file ${configPath}" ]
              [ (format != "auto") "--format ${format}" ]
              [ (preset != "default" && configuration == "") "--config-data ${preset}" ]
              [ strict "--strict" ]
            ]);
      in
      "${config.package}/bin/yamllint ${cmdArgs}";
  };
}

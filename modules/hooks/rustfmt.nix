{ lib, config, settings, ... }:
let
  inherit (lib) mkOption types;
  nameType = types.strMatching "[][*?!0-9A-Za-z_-]+";
in
{
  options = {
    packageOverrides = {
      cargo = mkOption {
        type = types.package;
        description = "The cargo package to use.";
      };
      rustfmt = mkOption {
        type = types.package;
        description = "The rustfmt package to use.";
      };
    };

    settings = {
      all = mkOption {
        type = types.bool;
        description = "Format all packages, and also their local path-based dependencies";
        default = true;
      };
      check = mkOption {
        type = types.bool;
        description = "Run rustfmt in check mode";
        default = false;
      };
      color = mkOption {
        type = types.enum [ "auto" "always" "never" ];
        description = "Coloring the output";
        default = "always";
      };
      config = mkOption {
        type = types.attrs;
        description = "Override configuration values";
        default = { };
        apply = config:
          let
            config' = lib.mapAttrsToList
              (key: value: "${key}=${toString value}")
              config;
          in
          if config == { } then "" else "--config=${lib.concatStringsSep "," config'}";
      };
      config-path = mkOption {
        type = types.nullOr types.str;
        description = "Path to the configuration file";
        default = null;
      };
      emit = mkOption {
        type = types.enum [ "files" "stdout" "coverage" "checkstyle" "json" ];
        description = "What data to emit and how";
        default = "files";
      };
      files-with-diff = mkOption {
        type = types.bool;
        description = "Print the names of mismatched files that were formatted. Prints the names of files that would be formatted when used with `--check` mode";
        default = config.settings.message-format == "short";
      };
      manifest-path = mkOption {
        type = types.nullOr types.str;
        description = "Path to Cargo.toml";
        default = settings.rust.cargoManifestPath;
      };
      message-format = mkOption {
        type = types.nullOr (types.enum [ "human" "short" ]);
        description = "The output format of diagnostic messages";
        default = null;
      };
      package = mkOption {
        type = types.listOf nameType;
        description = "Package(s) to check";
        default = [ ];
      };
      verbose = mkOption {
        type = types.bool;
        description = "Use verbose output";
        default = false;
      };
    };
  };

  config = {
    name = "rustfmt";
    description = "Format Rust code.";
    package = config.packageOverrides.rustfmt;
    entry =
      let
        cmdArgs =
          lib.mkCmdArgs (with config.settings; [
            [ (all) "--all" ]
            [ (check) "--check" ]
            [ (color != "auto") "--color ${color}" ]
            [ (config != { }) config ]
            [ (config-path != null) "--config-path ${lib.escapeShellArg config-path}" ]
            [ (emit != "files") "--emit ${emit}" ]
            [ (files-with-diff) "--files-with-diff" ]
            [ (manifest-path != null) "--manifest-path ${lib.escapeShellArg manifest-path}" ]
            [ (message-format != null) "--message-format ${message-format}" ]
            [ (package != [ ]) "--package ${lib.strings.concatStringsSep " --package " package}" ]
            [ verbose "-v" ]
          ]);
      in
      "${config.packageOverrides.rustfmt}/bin/rustfmt ${cmdArgs}";
    files = "\\.rs$";
    extraPackages = [
      config.packageOverrides.cargo
      config.packageOverrides.rustfmt
    ];
  };
}

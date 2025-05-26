{ lib, config, settings, pkgs, tools, ... }:
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

  config =
    let
      mkAdditionalArgs = args: lib.optionalString (args != "") " -- ${args}";

      wrapper = pkgs.symlinkJoin {
        name = "rustfmt-wrapped";
        paths = [ config.packageOverrides.rustfmt ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cargo-fmt \
          --prefix PATH : ${lib.makeBinPath (builtins.attrValues config.packageOverrides)}
        '';
      };
    in
    {
      package = wrapper;
      packageOverrides = { inherit (tools) cargo rustfmt; };
      entry =
        let
          cargoArgs = lib.cli.toGNUCommandLineShell { } {
            inherit (config.settings) all package verbose manifest-path;
          };
          rustfmtArgs = lib.cli.toGNUCommandLineShell { } {
            inherit (config.settings) check emit config-path color files-with-diff config verbose;
          };
        in
        "${config.package}/bin/cargo-fmt fmt ${cargoArgs}${mkAdditionalArgs rustfmtArgs}";
      files = "\\.rs$";
      pass_filenames = false;
      extraPackages = [
        config.packageOverrides.cargo
        config.packageOverrides.rustfmt
      ];
    };
}

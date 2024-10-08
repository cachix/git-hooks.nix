{ config, lib, hookModule, ... }:

let
  inherit (builtins) concatStringsSep removeAttrs toString;
  inherit (config) hooks settings;
  inherit (lib) mkOption types;

  commonCargoSettings = import ./common-settings.nix {
    inherit lib;
    inherit (settings.rust) cargoManifestPath;
  };
in
{
  cargo-bench = mkOption {
    description = "cargo bench hook";
    type = types.submodule
      ({ config, ... }: {
        imports = [ hookModule ];
        options = {
          packageOverrides = {
            cargo = mkOption {
              type = types.package;
              description = "The cargo package to use";
            };
          };
          settings = (removeAttrs commonCargoSettings [ "release" ]) // {
            bench-args = mkOption {
              type = types.attrs;
              description = "Arguments for the bench binaries";
              default = { };
            };
            no-fail-fast = mkOption {
              type = types.bool;
              description = "Run all bench targets regardless of failure";
              default = false;
            };
          };
        };
        config.extraPackages = [
          config.packageOverrides.cargo
        ];
      });
  };

  cargo-check = mkOption {
    description = "cargo check hook";
    type = types.submodule
      ({ config, ... }: {
        imports = [ hookModule ];
        options = {
          packageOverrides = {
            cargo = mkOption {
              type = types.package;
              description = "The cargo package to use";
            };
          };
          settings = commonCargoSettings;
        };
        config.extraPackages = [
          config.packageOverrides.cargo
        ];
      });
  };

  cargo-doc = mkOption {
    description = "cargo doc hook";
    type = types.submodule ({ config, ... }: {
      imports = [ hookModule ];
      options = {
        packageOverrides = {
          cargo = mkOption {
            type = types.package;
            description = "The cargo package to use";
          };
        };
        settings = (removeAttrs commonCargoSettings [
          "all-targets"
          "bench"
          "benches"
          "test"
          "tests"
          "future-incompat-report"
        ]) // {
          document-private-items = mkOption {
            type = types.bool;
            description = "Include non-public items in the documentation.";
            default = false;
          };
          no-deps = mkOption {
            type = types.bool;
            description = "Do not build documentation for dependencies";
            default = false;
          };
        };
      };
      config.extraPackages = [
        config.packageOverrides.cargo
      ];
    });
  };

  cargo-test = mkOption {
    description = "cargo test hook";
    type = types.submodule ({ config, ... }: {
      imports = [ hookModule ];
      options = {
        packageOverrides = {
          cargo = mkOption {
            type = types.package;
            description = "The cargo package to use";
          };
        };
        settings = commonCargoSettings // {
          no-fail-fast = mkOption {
            type = types.bool;
            description = "Run all tests regardless of failure";
            default = false;
          };
          test-args = mkOption {
            type = types.attrs;
            description = "Arguments for the test binaries";
            default = { };
          };
        };
      };
      config.extraPackages = [
        config.packageOverrides.cargo
      ];
    });
  };

  clippy = mkOption {
    description = "clippy hook";
    type = types.submodule
      ({ config, ... }: {
        imports = [ hookModule ];
        options = {
          packageOverrides = {
            cargo = mkOption {
              type = types.package;
              description = "The cargo package to use";
            };
            clippy = mkOption {
              type = types.package;
              description = "The clippy package to use";
            };
          };
          settings =
            let
              lintType = types.strMatching "[0-9a-z_]";
            in
            commonCargoSettings // {
              allFeatures = commonCargoSettings.all-features // {
                visible = false;
              };
              all-features = commonCargoSettings.all-features // {
                default = hooks.clippy.settings.allFeatures;
              };
              allow = mkOption {
                type = types.listOf lintType;
                description = "Set lint allowed";
                default = [ ];
              };
              deny = mkOption {
                type = types.listOf lintType;
                description = "Set lint denied";
                default = [ ];
                apply = deny:
                  deny ++ lib.optional hooks.clippy.settings.denyWarnings "warnings";
              };
              denyWarnings = mkOption {
                type = types.bool;
                description = "Fail when warnings are present";
                default = false;
                visible = false;
              };
              extraArgs = mkOption {
                type = types.str;
                description = "Additional arguments to pass to clippy";
                default = "";
              };
              fix = mkOption {
                type = types.bool;
                description = ''
                  Automatically apply lint suggestions.
                  This flag implies `--no-deps` and `--all-targets`.
                '';
                default = false;
              };
              forbid = mkOption {
                type = types.listOf lintType;
                description = "Set lint forbidden";
                default = [ ];
              };
              no-deps = mkOption {
                type = types.bool;
                description = "Run Clippy only on the given crate, without linting the dependencies";
                default = false;
              };
              warn = mkOption {
                type = types.listOf lintType;
                description = "Set lint warnings";
                default = [ ];
              };
            };
        };
        config.extraPackages = [
          config.packageOverrides.cargo
          config.packageOverrides.clippy
        ];
      });
  };

  rustfmt = mkOption {
    description = ''
      Additional settings

      Override the `rustfmt` and `cargo` packages by setting `hooks.rustfmt.packageOverrides`.

      ```
      hooks.rustfmt.packageOverrides.cargo = pkgs.cargo;
      hooks.rustfmt.packageOverrides.rustfmt = pkgs.rustfmt;
      ```
    '';
    type = types.submodule ({ config, ... }: {
      imports = [ hookModule ];
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
        settings =
          let
            nameType = types.strMatching "[][*?!0-9A-Za-z_-]+";
          in
          {
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
                lib.optionalString (config != { }) (concatStringsSep "," config');
            };
            config-path = mkOption {
              type = types.nullOr types.str;
              description = "Path to rustfmt.toml config file";
              default = null;
            };
            emit = mkOption {
              type = types.nullOr (types.enum [ "files" "stdout" ]);
              description = "What data to emit and how";
              default = null;
            };
            files-with-diff = mkOption {
              type = types.bool;
              description = "";
              default = hooks.rustfmt.settings.message-format == "short";
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
      config.extraPackages = [
        config.packageOverrides.cargo
        config.packageOverrides.rustfmt
      ];
    });
  };
}

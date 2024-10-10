{ lib, cargoManifestPath, ... }:
let
  inherit (builtins) concatStringsSep isAttrs toString;
  inherit (lib) types mkOption;

  nameType = types.strMatching "[][*?!0-9A-Za-z_-]+";
  featureNameType = types.strMatching "([0-9A-Za-z_-]+/)?[0-9A-Za-z_+-]+";
  profileNameType = types.strMatching "[0-9A-Za-z_-]+";
  tripleType = types.strMatching "^([0-9a-z_.]+)(-[0-9a-z_]+){1,3}$";
in
{
  # Package Selection:
  exclude = mkOption {
    type = types.listOf nameType;
    description = "Exclude packages from the check";
    default = [ ];
  };
  package = mkOption {
    type = types.listOf nameType;
    description = "Package(s) to check";
    default = [ ];
  };
  workspace = mkOption {
    type = types.bool;
    description = "Check all packages in the workspace";
    default = false;
  };

  # Target Selection:
  all-targets = mkOption {
    type = types.bool;
    description = "Check all targets";
    default = false;
  };
  bench = mkOption {
    type = types.listOf nameType;
    description = "Check only the specified bench targets";
    default = [ ];
  };
  benches = mkOption {
    type = types.bool;
    description = "Check all bench targets";
    default = false;
  };
  bin = mkOption {
    type = types.listOf nameType;
    description = "Check only the specified binaries";
    default = [ ];
  };
  bins = mkOption {
    type = types.bool;
    description = "Check all binaries";
    default = false;
  };
  example = mkOption {
    type = types.listOf nameType;
    description = "Check only the specified examples";
    default = [ ];
  };
  examples = mkOption {
    type = types.bool;
    description = "Check all examples";
    default = false;
  };
  lib = mkOption {
    type = types.bool;
    description = "Check only this package's library";
    default = false;
  };
  test = mkOption {
    type = types.listOf nameType;
    description = "Check only the specified test targets";
    default = [ ];
  };
  tests = mkOption {
    type = types.bool;
    description = "Check all test targets";
    default = false;
  };

  # Feature Selection:
  all-features = mkOption {
    type = types.bool;
    description = "Activate all available features";
    default = false;
  };
  features = mkOption {
    type = types.listOf featureNameType;
    description = "List of features to activate";
    default = [ ];
    apply = features: lib.optional (features != [ ]) (concatStringsSep "," features);
  };
  no-default-features = mkOption {
    type = types.bool;
    description = "Do not activate the `default` feature";
    default = false;
  };

  # Compilation Options:
  ignore-rust-version = mkOption {
    type = types.bool;
    description = "Ignore `rust-version` specification in packages";
    default = false;
  };
  profile = mkOption {
    type = types.nullOr profileNameType;
    description = "Check artifacts with the specified profile";
    default = null;
  };
  release = mkOption {
    type = types.bool;
    description = "Check artifacts in release mode, with optimizations";
    default = false;
  };
  target = mkOption {
    type = types.listOf tripleType;
    description = "Check for the target triple(s)";
    default = [ ];
  };
  timings = mkOption {
    type = types.bool;
    description = "Output information how long each compilation takes";
    default = false;
  };

  # Output Options:
  target-dir = mkOption {
    type = types.nullOr types.path;
    description = "Directory for all generated artifacts";
    default = null;
  };

  # Display Options:
  color = mkOption {
    type = types.enum [ "auto" "always" "never" ];
    description = "Coloring the output";
    default = "always";
  };
  message-format = mkOption {
    type = types.nullOr (types.enum [ "human" "short" ]);
    description = "The output format of diagnostic messages";
    default = null;
  };
  verbose = mkOption {
    type = types.bool;
    description = "Use verbose output";
    default = false;
  };

  # Manifest Options:
  frozen = mkOption {
    type = types.bool;
    description = "Require Cargo.lock and cache are up to date";
    default = false;
  };
  locked = mkOption {
    type = types.bool;
    description = "Require Cargo.lock is up to date";
    default = false;
  };
  manifest-path = mkOption {
    type = types.nullOr types.str;
    description = "Path to Cargo.toml";
    default = cargoManifestPath;
  };
  offline = mkOption {
    type = types.bool;
    description = "Run without accessing the network";
    default = false;
  };

  # Common Options:
  config = mkOption {
    type = types.either types.str types.attrs;
    description = "Override configuration values";
    default = { };
    apply = config:
      if isAttrs config
      then
        lib.mapAttrsToList
          (key: value: "${key}=${toString value}")
          config
      else
        config;
  };
  Z = mkOption {
    type = types.listOf types.str;
    description = "Unstable (nightly-only) flags to Cargo";
    default = [ ];
  };

  # Miscellaneous Options:
  future-incompat-report = mkOption {
    type = types.bool;
    description = "Outputs a future incompatibility report at the end of the build";
    default = false;
  };
  jobs = mkOption {
    type = types.nullOr types.ints.positive;
    description = "Number of parallel jobs, defaults to # of CPUs";
    default = null;
  };
  keep-going = mkOption {
    type = types.bool;
    description = "Do not abort the build as soon as there is an error";
    default = false;
  };
}

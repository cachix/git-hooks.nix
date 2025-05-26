{ config, lib, pkgs, settings, ... }:
let
  inherit (lib) mkOption types;
  inherit (settings.rust) cargoManifestPath;

  cargoManifestPathArg =
    lib.optionalString
      (cargoManifestPath != null)
      "--manifest-path ${lib.escapeShellArg cargoManifestPath}";

  wrapper = pkgs.symlinkJoin {
    name = "clippy-wrapped";
    paths = [ config.packageOverrides.clippy ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cargo-clippy \
        --prefix PATH : ${lib.makeBinPath [ config.packageOverrides.cargo ]}
    '';
  };
in
{
  options = {
    settings = {
      denyWarnings = mkOption {
        type = types.bool;
        description = "Fail when warnings are present";
        default = false;
      };
      offline = mkOption {
        type = types.bool;
        description = "Run clippy offline";
        default = true;
      };
      allFeatures = mkOption {
        type = types.bool;
        description = "Run clippy with --all-features";
        default = false;
      };
      extraArgs = mkOption {
        type = types.str;
        description = "Additional arguments to pass to clippy";
        default = "";
      };
    };

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
  };

  config = {
    name = "clippy";
    description = "Lint Rust code.";
    package = wrapper;
    packageOverrides = { cargo = config.packageOverrides.cargo; clippy = config.packageOverrides.clippy; };
    entry = "${wrapper}/bin/cargo-clippy clippy ${cargoManifestPathArg} ${lib.optionalString config.settings.offline "--offline"} ${lib.optionalString config.settings.allFeatures "--all-features"} ${config.settings.extraArgs} -- ${lib.optionalString config.settings.denyWarnings "-D warnings"}";
    files = "\\.rs$";
    pass_filenames = false;
    extraPackages = [
      config.packageOverrides.cargo
      config.packageOverrides.clippy
    ];
  };
}

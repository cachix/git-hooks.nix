{ tools, lib, settings, config, ... }:
let
  inherit (settings.rust) cargoManifestPath;
  cargoManifestPathArg =
    lib.optionalString
      (cargoManifestPath != null)
      "--manifest-path ${lib.escapeShellArg cargoManifestPath}";
in
{
  config = {
    name = "cargo-check";
    description = "Check the cargo package for errors";
    package = tools.cargo;
    entry = "${config.package}/bin/cargo check ${cargoManifestPathArg}";
    files = "\\.rs$";
    pass_filenames = false;
  };
}

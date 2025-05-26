{ tools, lib, settings, ... }:
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
    entry = "${tools.cargo}/bin/cargo check ${cargoManifestPathArg}";
    files = "\\.rs$";
    pass_filenames = false;
  };
}

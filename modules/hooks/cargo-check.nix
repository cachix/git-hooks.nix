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
    package = tools.cargo;
    entry = "${config.package}/bin/cargo check ${cargoManifestPathArg}";
    files = "\\.rs$";
    pass_filenames = false;
  };
}

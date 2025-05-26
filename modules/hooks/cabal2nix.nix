{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    outputFilename =
      mkOption {
        type = types.str;
        description = "The name of the output file generated after running `cabal2nix`.";
        default = "default.nix";
      };
  };

  config = {
    package = tools.cabal2nix-dir;
    entry = "${config.package}/bin/cabal2nix-dir --outputFileName=${config.settings.outputFilename}";
    files = "\\.cabal$";
    after = [ "hpack" ];
  };
}

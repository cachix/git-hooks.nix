{ lib, ... }:
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
}

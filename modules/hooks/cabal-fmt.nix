{ tools, lib, config, ... }:
{
  config = {
    name = "cabal-fmt";
    description = "Format Cabal files";
    package = tools.cabal-fmt;
    entry = "${config.package}/bin/cabal-fmt --inplace";
    files = "\\.cabal$";
  };
}

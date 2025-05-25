{ tools, lib, ... }:
{
  config = {
    name = "cabal-fmt";
    description = "Format Cabal files";
    package = tools.cabal-fmt;
    entry = "${tools.cabal-fmt}/bin/cabal-fmt --inplace";
    files = "\\.cabal$";
  };
}
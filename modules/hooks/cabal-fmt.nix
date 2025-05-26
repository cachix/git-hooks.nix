{ tools, lib, config, ... }:
{
  config = {
    package = tools.cabal-fmt;
    entry = "${config.package}/bin/cabal-fmt --inplace";
    files = "\\.cabal$";
  };
}

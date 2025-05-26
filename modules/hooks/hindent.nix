{ tools, lib, config, ... }:
{
  config = {
    name = "hindent";
    description = "Haskell code prettifier.";
    package = tools.hindent;
    entry = "${config.package}/bin/hindent";
    files = "\.l?hs$";
  };
}

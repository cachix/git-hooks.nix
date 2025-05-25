{ tools, lib, ... }:
{
  config = {
    name = "hindent";
    description = "Haskell code prettifier.";
    package = tools.hindent;
    entry = "${tools.hindent}/bin/hindent";
    files = "\.l?hs$";
  };
}
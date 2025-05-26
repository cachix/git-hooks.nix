{ tools, lib, config, ... }:
{
  config = {
    name = "stylish-haskell";
    description = "A simple Haskell code prettifier.";
    package = tools.stylish-haskell;
    entry = "${config.package}/bin/stylish-haskell --inplace";
    files = "\\.l?hs(-boot)?$";
  };
}

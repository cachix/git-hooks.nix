{ tools, lib, ... }:
{
  config = {
    name = "stylish-haskell";
    description = "A simple Haskell code prettifier.";
    package = tools.stylish-haskell;
    entry = "${tools.stylish-haskell}/bin/stylish-haskell --inplace";
    files = "\.l?hs$";
  };
}
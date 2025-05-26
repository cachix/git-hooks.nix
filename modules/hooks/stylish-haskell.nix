{ tools, lib, config, ... }:
{
  config = {
    package = tools.stylish-haskell;
    entry = "${config.package}/bin/stylish-haskell --inplace";
    files = "\\.l?hs(-boot)?$";
  };
}

{ tools, config, lib, ... }:
{
  config = {
    name = "purty";
    description = "Format purescript files.";
    package = tools.purty;
    entry = "${config.package}/bin/purty";
    files = "\\.purs$";
  };
}

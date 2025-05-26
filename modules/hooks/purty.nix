{ tools, config, lib, ... }:
{
  config = {
    package = tools.purty;
    entry = "${config.package}/bin/purty";
    files = "\\.purs$";
  };
}

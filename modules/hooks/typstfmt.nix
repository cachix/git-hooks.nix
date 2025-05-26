{ tools, lib, config, ... }:
{
  config = {
    package = tools.typstfmt;
    entry = "${config.package}/bin/typstfmt";
    files = "\\.typ$";
  };
}

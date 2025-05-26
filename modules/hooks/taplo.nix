{ tools, lib, config, ... }:
{
  config = {
    name = "taplo";
    description = "Format TOML files with taplo fmt.";
    package = tools.taplo;
    entry = "${config.package}/bin/taplo fmt";
    types = [ "toml" ];
  };
}

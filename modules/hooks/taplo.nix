{ tools, lib, config, ... }:
{
  config = {
    package = tools.taplo;
    entry = "${config.package}/bin/taplo fmt";
    types = [ "toml" ];
  };
}

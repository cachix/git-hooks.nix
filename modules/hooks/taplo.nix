{ tools, lib, ... }:
{
  config = {
    name = "taplo";
    description = "Format TOML files with taplo fmt.";
    package = tools.taplo;
    entry = "${tools.taplo}/bin/taplo format";
    types = [ "toml" ];
  };
}
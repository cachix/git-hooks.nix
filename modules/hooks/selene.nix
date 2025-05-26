{ tools, lib, config, ... }:
{
  config = {
    package = tools.selene;
    entry = "${config.package}/bin/selene";
    types = [ "lua" ];
  };
}

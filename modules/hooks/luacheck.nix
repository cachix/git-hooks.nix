{ tools, config, lib, ... }:
{
  config = {
    package = tools.luacheck;
    entry = "${config.package}/bin/luacheck";
    types = [ "lua" ];
  };
}

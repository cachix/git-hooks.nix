{ tools, config, lib, ... }:
{
  config = {
    name = "luacheck";
    description = "A tool for linting and static analysis of Lua code.";
    package = tools.luacheck;
    entry = "${config.package}/bin/luacheck";
    types = [ "lua" ];
  };
}

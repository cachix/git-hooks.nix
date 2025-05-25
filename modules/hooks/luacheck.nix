{ tools, lib, ... }:
{
  config = {
    name = "luacheck";
    description = "A tool for linting and static analysis of Lua code.";
    package = tools.luacheck;
    entry = "${tools.luacheck}/bin/luacheck";
    types = [ "lua" ];
  };
}
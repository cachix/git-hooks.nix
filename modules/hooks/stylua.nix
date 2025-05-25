{ tools, lib, ... }:
{
  config = {
    name = "stylua";
    description = "An opinionated code formatter for Lua.";
    package = tools.stylua;
    entry = "${tools.stylua}/bin/stylua";
    types = [ "lua" ];
  };
}
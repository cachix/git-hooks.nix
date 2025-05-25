{ tools, lib, ... }:
{
  config = {
    name = "selene";
    description = "A blazing-fast modern Lua linter.";
    package = tools.selene;
    entry = "${tools.selene}/bin/selene";
    types = [ "lua" ];
  };
}
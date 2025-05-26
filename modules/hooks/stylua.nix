{ tools, lib, config, ... }:
{
  config = {
    name = "stylua";
    description = "An opinionated code formatter for Lua.";
    package = tools.stylua;
    entry = "${config.package}/bin/stylua --respect-ignores";
    types = [ "file" "lua" ];
  };
}

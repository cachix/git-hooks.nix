{ tools, lib, config, ... }:
{
  config = {
    name = "selene";
    description = "A blazing-fast modern Lua linter written in Rust.";
    package = tools.selene;
    entry = "${config.package}/bin/selene";
    types = [ "lua" ];
  };
}

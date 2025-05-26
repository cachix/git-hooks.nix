{ tools, lib, config, ... }:
{
  config = {
    package = tools.stylua;
    entry = "${config.package}/bin/stylua --respect-ignores";
    types = [ "file" "lua" ];
  };
}

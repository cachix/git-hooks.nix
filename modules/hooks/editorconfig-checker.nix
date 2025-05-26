{ config, tools, lib, ... }:
{
  config = {
    package = tools.editorconfig-checker;
    entry = "${config.package}/bin/editorconfig-checker";
    types = [ "file" ];
  };
}

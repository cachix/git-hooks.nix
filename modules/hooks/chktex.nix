{ config, tools, lib, ... }:
{
  config = {
    types = [ "file" "tex" ];
    package = tools.chktex;
    entry = "${config.package}/bin/chktex";
  };
}

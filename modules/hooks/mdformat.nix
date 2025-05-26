{ config, tools, lib, ... }:
{
  config = {
    package = tools.mdformat;
    entry = "${config.package}/bin/mdformat";
    types = [ "markdown" ];
  };
}

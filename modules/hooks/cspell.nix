{ config, tools, lib, ... }:
{
  config = {
    package = tools.cspell;
    entry = "${config.package}/bin/cspell --no-summary";
    types = [ "text" ];
  };
}

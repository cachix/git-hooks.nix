{ config, tools, lib, ... }:
{
  config = {
    package = tools.hunspell;
    entry = "${config.package}/bin/hunspell -l";
    types = [ "text" ];
  };
}

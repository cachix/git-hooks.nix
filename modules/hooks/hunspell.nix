{ config, tools, lib, ... }:
{
  config = {
    name = "hunspell";
    description = "Spell checker and morphological analyzer.";
    package = tools.hunspell;
    entry = "${config.package}/bin/hunspell -l";
    types = [ "text" ];
  };
}

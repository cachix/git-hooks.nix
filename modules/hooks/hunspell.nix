{ tools, lib, ... }:
{
  config = {
    name = "hunspell";
    description = "Spell checker and morphological analyzer.";
    package = tools.hunspell;
    entry = "${tools.hunspell}/bin/hunspell -l";
    types = [ "text" ];
  };
}
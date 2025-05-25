{ tools, lib, ... }:
{
  config = {
    name = "cspell";
    description = "A Spell Checker for Code";
    package = tools.cspell;
    entry = "${tools.cspell}/bin/cspell --no-summary";
    types = [ "text" ];
  };
}
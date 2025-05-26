{ config, tools, lib, ... }:
{
  config = {
    name = "cspell";
    description = "A Spell Checker for Code";
    package = tools.cspell;
    entry = "${config.package}/bin/cspell --no-summary";
    types = [ "text" ];
  };
}

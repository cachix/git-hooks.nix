{ tools, lib, ... }:
{
  config = {
    name = "dhall-format";
    description = "Dhall code formatter.";
    package = tools.dhall;
    entry = "${tools.dhall}/bin/dhall format";
    files = "\.dhall$";
  };
}
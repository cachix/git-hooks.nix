{ config, tools, lib, ... }:
{
  config = {
    name = "dhall-format";
    description = "Dhall code formatter.";
    package = tools.dhall;
    entry = "${config.package}/bin/dhall format";
    files = "\.dhall$";
  };
}

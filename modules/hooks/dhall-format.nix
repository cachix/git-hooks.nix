{ config, tools, lib, ... }:
{
  config = {
    package = tools.dhall;
    entry = "${config.package}/bin/dhall format";
    files = "\.dhall$";
  };
}

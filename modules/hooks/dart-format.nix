{ config, tools, lib, ... }:
{
  config = {
    package = tools.dart;
    entry = "${config.package}/bin/dart format";
    types = [ "dart" ];
  };
}

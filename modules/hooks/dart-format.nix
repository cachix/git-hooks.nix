{ config, tools, lib, ... }:
{
  config = {
    name = "dart format";
    description = "Dart formatter";
    package = tools.dart;
    entry = "${config.package}/bin/dart format";
    types = [ "dart" ];
  };
}

{ config, tools, lib, ... }:
{
  config = {
    name = "dart analyze";
    description = "Dart analyzer";
    package = tools.dart;
    entry = "${config.package}/bin/dart analyze";
    types = [ "dart" ];
  };
}

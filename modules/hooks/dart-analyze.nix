{ tools, lib, ... }:
{
  config = {
    name = "dart analyze";
    description = "Dart analyzer";
    package = tools.dart;
    entry = "${tools.dart}/bin/dart analyze";
    types = [ "dart" ];
  };
}
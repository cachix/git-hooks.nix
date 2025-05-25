{ tools, lib, ... }:
{
  config = {
    name = "dart format";
    description = "Dart formatter";
    package = tools.dart;
    entry = "${tools.dart}/bin/dart format";
    types = [ "dart" ];
  };
}
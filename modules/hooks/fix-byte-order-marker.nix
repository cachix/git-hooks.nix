{ tools, lib, ... }:
{
  config = {
    name = "fix-byte-order-marker";
    description = "Remove UTF-8 byte order marker.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/fix-byte-order-marker";
    types = [ "text" ];
  };
}
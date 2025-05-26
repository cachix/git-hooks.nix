{ config, tools, lib, ... }:
{
  config = {
    name = "fix-byte-order-marker";
    description = "Remove UTF-8 byte order marker.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/fix-byte-order-marker";
    types = [ "text" ];
  };
}

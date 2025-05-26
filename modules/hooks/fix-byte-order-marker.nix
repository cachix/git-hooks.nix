{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/fix-byte-order-marker";
    types = [ "text" ];
  };
}

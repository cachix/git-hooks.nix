{ config, tools, lib, ... }:
{
  config = {
    files = "^.github/workflows/";
    types = [ "yaml" ];
    package = tools.actionlint;
    entry = "${config.package}/bin/actionlint";
  };
}

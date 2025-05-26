{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/end-of-file-fixer";
    types = [ "text" ];
  };
}

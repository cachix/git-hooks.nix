{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-case-conflict";
    types = [ "file" ];
  };
}

{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/debug-statement-hook";
    types = [ "python" ];
  };
}

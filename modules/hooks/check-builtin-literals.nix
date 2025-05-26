{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-builtin-literals";
    types = [ "python" ];
  };
}

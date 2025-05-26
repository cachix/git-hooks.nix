{ tools, lib, config, ... }:
{
  config = {
    name = "mixed-line-endings";
    description = "Resolve mixed line endings.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/mixed-line-ending";
    types = [ "text" ];
  };
}

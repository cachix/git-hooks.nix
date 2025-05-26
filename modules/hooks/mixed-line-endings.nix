{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/mixed-line-ending";
    types = [ "text" ];
  };
}

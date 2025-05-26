{ tools, lib, config, ... }:
{
  config = {
    types = [ "shell" ];
    package = tools.beautysh;
    entry = "${config.package}/bin/beautysh";
  };
}

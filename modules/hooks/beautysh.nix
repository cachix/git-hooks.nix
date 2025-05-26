{ tools, lib, config, ... }:
{
  config = {
    name = "beautysh";
    description = "Format shell files";
    types = [ "shell" ];
    package = tools.beautysh;
    entry = "${config.package}/bin/beautysh";
  };
}

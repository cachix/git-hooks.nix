{ tools, lib, ... }:
{
  config = {
    name = "beautysh";
    description = "Format shell files";
    types = [ "shell" ];
    package = tools.beautysh;
    entry = "${tools.beautysh}/bin/beautysh";
  };
}
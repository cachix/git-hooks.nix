{ config, tools, lib, ... }:
{
  config = {
    name = "fprettify";
    description = "Auto-formatter for modern Fortran code.";
    types = [ "fortran " ];
    package = tools.fprettify;
    entry = "${config.package}/bin/fprettify";
  };
}

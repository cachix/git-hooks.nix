{ tools, lib, ... }:
{
  config = {
    name = "fprettify";
    description = "Auto-formatter for modern Fortran code.";
    types = [ "fortran " ];
    package = tools.fprettify;
    entry = "${tools.fprettify}/bin/fprettify";
  };
}
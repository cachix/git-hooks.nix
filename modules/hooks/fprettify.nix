{ config, tools, lib, ... }:
{
  config = {
    types = [ "fortran " ];
    package = tools.fprettify;
    entry = "${config.package}/bin/fprettify";
  };
}

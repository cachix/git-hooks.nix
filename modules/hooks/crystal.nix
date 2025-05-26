{ config, tools, lib, ... }:
{
  config = {
    package = tools.crystal;
    entry = "${config.package}/bin/crystal tool format";
    files = "\.cr$";
  };
}

{ config, tools, lib, ... }:
{
  config = {
    name = "crystal";
    description = "A tool that automatically formats Crystal source code";
    package = tools.crystal;
    entry = "${config.package}/bin/crystal tool format";
    files = "\.cr$";
  };
}

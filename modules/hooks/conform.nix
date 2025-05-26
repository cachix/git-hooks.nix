{ config, tools, lib, ... }:
{
  config = {
    package = tools.conform;
    entry = "${config.package}/bin/conform enforce --commit-msg-file";
    stages = [ "commit-msg" ];
  };
}

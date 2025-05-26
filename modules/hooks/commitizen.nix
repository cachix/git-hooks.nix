{ config, tools, lib, ... }:
{
  config = {
    package = tools.commitizen;
    entry = "${config.package}/bin/cz check --allow-abort --commit-msg-file";
    stages = [ "commit-msg" ];
  };
}


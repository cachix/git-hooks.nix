{ config, tools, lib, ... }:
{
  config = {
    name = "conform enforce";
    description = "Policy enforcement for commits.";
    package = tools.conform;
    entry = "${config.package}/bin/conform enforce --commit-msg-file";
    stages = [ "commit-msg" ];
  };
}

{ tools, lib, ... }:
{
  config = {
    name = "conform enforce";
    description = "Policy enforcement for commits.";
    package = tools.conform;
    entry = "${tools.conform}/bin/conform enforce --commit-msg-file";
    stages = [ "commit-msg" ];
  };
}
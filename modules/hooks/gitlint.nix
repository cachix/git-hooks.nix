{ config, tools, lib, ... }:
{
  config = {
    package = tools.gitlint;
    entry = "${config.package}/bin/gitlint --staged --msg-filename";
    stages = [ "commit-msg" ];
  };
}

{ config, tools, lib, ... }:
{
  config = {
    name = "gitlint";
    description = "Linting for your git commit messages";
    package = tools.gitlint;
    entry = "${config.package}/bin/gitlint --staged --msg-filename";
    stages = [ "commit-msg" ];
  };
}

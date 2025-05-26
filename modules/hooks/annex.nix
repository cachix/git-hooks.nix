{ config, tools, lib, ... }:
{
  config = {
    name = "annex";
    description = "Runs the git-annex hook for large file support";
    package = tools.git-annex;
    entry = "${config.package}/bin/git-annex pre-commit";
  };
}

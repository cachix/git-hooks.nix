{ config, tools, lib, ... }:
{
  config = {
    package = tools.git-annex;
    entry = "${config.package}/bin/git-annex pre-commit";
  };
}

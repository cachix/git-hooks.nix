{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/detect-aws-credentials --allow-missing-credentials";
    types = [ "text" ];
  };
}

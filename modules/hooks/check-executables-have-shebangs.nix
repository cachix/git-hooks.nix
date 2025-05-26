{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-executables-have-shebangs";
    types = [ "text" "executable" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}

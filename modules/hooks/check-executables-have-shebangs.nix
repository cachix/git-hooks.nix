{ tools, lib, ... }:
{
  config = {
    name = "check-executables-have-shebangs";
    description = "Ensure that all non-binary executables have shebangs.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-executables-have-shebangs";
    types = [ "text" "executable" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}
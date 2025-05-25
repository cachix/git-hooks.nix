{ tools, lib, ... }:
{
  config = {
    name = "check-toml";
    description = "Check syntax of TOML files.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-toml";
    types = [ "toml" ];
  };
}
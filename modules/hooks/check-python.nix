{ tools, lib, config, ... }:
{
  config = {
    name = "check-python";
    description = "Check syntax of Python file by parsing Python abstract syntax tree.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-ast";
    types = [ "python" ];
  };
}

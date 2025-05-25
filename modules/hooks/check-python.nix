{ tools, lib, ... }:
{
  config = {
    name = "check-python";
    description = "Check syntax of Python file by parsing Python abstract syntax tree.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-ast";
    types = [ "python" ];
  };
}
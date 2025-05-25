{ tools, lib, ... }:
{
  config = {
    name = "debug-statements";
    description = "Check for debugger imports and py37+ `breakpoint()` calls in python source.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/debug-statement-hook";
    types = [ "python" ];
  };
}
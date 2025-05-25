{ tools, lib, ... }:
{
  config = {
    name = "check-builtin-literals";
    description = "Require literal syntax when initializing empty or zero builtin types in Python.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-builtin-literals";
    types = [ "python" ];
  };
}
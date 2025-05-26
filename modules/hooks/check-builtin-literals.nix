{ tools, lib, config, ... }:
{
  config = {
    name = "check-builtin-literals";
    description = "Require literal syntax when initializing empty or zero builtin types in Python.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-builtin-literals";
    types = [ "python" ];
  };
}

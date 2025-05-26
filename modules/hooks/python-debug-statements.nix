{ tools, lib, config, ... }:
{
  config = {
    name = "debug-statements";
    description = "Check for debugger imports and py37+ `breakpoint()` calls in python source.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/debug-statement-hook";
    types = [ "python" ];
  };
}

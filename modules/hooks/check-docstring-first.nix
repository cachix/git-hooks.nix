{ tools, lib, config, ... }:
{
  config = {
    name = "check-docstring-above";
    description = "Check that all docstrings appear above the code.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-docstring-first";
    types = [ "python" ];
  };
}

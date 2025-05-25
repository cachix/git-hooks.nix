{ tools, lib, ... }:
{
  config = {
    name = "check-docstring-above";
    description = "Check that all docstrings appear above the code.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-docstring-first";
    types = [ "python" ];
  };
}
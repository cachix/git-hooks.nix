{ tools, lib, ... }:
{
  config = {
    name = "mixed-line-ending";
    description = "Check for mixed line endings.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/mixed-line-ending";
    types = [ "text" ];
  };
}
{ tools, lib, ... }:
{
  config = {
    name = "check-shebang-scripts-are-executable";
    description = "Ensure that all (non-binary) files with a shebang are executable.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-shebang-scripts-are-executable";
    types = [ "text" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}
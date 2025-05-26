{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-shebang-scripts-are-executable";
    types = [ "text" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}

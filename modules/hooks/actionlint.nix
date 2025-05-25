{ tools, lib, ... }:
{
  config = {
    name = "actionlint";
    description = "Static checker for GitHub Actions workflow files";
    files = "^.github/workflows/";
    types = [ "yaml" ];
    package = tools.actionlint;
    entry = "${tools.actionlint}/bin/actionlint";
  };
}
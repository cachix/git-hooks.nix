{ tools, lib, ... }:
{
  config = {
    name = "single-quoted-strings";
    description = "Replace double quoted strings with single quoted strings.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/single-quoted-strings";
    types = [ "python" ];
  };
}
{ tools, lib, config, ... }:
{
  config = {
    name = "single-quoted-strings";
    description = "Replace double quoted strings with single quoted strings.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/double-quote-string-fixer";
    types = [ "python" ];
  };
}

{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/double-quote-string-fixer";
    types = [ "python" ];
  };
}

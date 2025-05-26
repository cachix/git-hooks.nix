{ tools, lib, config, ... }:
{
  config = {
    name = "shellcheck";
    description = "Format shell files";
    package = tools.shellcheck;
    entry = "${config.package}/bin/shellcheck";
    types = [ "shell" ];
  };
}

{ tools, lib, config, ... }:
{
  config = {
    package = tools.shellcheck;
    entry = "${config.package}/bin/shellcheck";
    types = [ "shell" ];
  };
}

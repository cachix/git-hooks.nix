{ tools, lib, config, ... }:
{
  config = {
    name = "bats";
    description = "Run bash unit tests";
    types = [ "shell" ];
    types_or = [ "bats" "bash" ];
    package = tools.bats;
    entry = "${config.package}/bin/bats -p";
  };
}

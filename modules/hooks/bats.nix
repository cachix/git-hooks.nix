{ tools, lib, ... }:
{
  config = {
    name = "bats";
    description = "Run bash unit tests";
    types = [ "shell" ];
    types_or = [ "bats" "bash" ];
    package = tools.bats;
    entry = "${tools.bats}/bin/bats -p";
  };
}
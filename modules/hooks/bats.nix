{ tools, lib, config, ... }:
{
  config = {
    types = [ "shell" ];
    types_or = [ "bats" "bash" ];
    package = tools.bats;
    entry = "${config.package}/bin/bats -p";
  };
}

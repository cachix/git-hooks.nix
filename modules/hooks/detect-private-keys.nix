{ tools, lib, ... }:
{
  config = {
    name = "detect-private-keys";
    description = "Detect the presence of private keys.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/detect-private-key";
    types = [ "text" ];
  };
}
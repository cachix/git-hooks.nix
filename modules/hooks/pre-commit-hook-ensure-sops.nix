{ tools, lib, config, ... }:
{
  config = {
    name = "pre-commit-hook-ensure-sops";
    description = "Ensure that sops files are encrypted.";
    package = tools.pre-commit-hook-ensure-sops;
    entry = "${config.package}/bin/pre-commit-hook-ensure-sops";
    files = "^secrets";
  };
}

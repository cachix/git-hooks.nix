{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hook-ensure-sops;
    entry = "${config.package}/bin/pre-commit-hook-ensure-sops";
    files = "^secrets";
  };
}

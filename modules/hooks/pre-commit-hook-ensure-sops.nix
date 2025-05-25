{ tools, lib, ... }:
{
  config = {
    name = "pre-commit-hook-ensure-sops";
    description = "Ensure that sops files are encrypted.";
    package = tools.pre-commit-hook-ensure-sops;
    entry = "${tools.pre-commit-hook-ensure-sops}/bin/pre-commit-hook-ensure-sops";
    files = "\.sops\.(ya?ml|json)$";
  };
}
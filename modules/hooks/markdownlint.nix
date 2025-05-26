{ config, lib, pkgs, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configuration =
      mkOption {
        type = types.attrs;
        description =
          "See https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc";
        default = { };
      };
  };

  config = {
    package = tools.markdownlint-cli;
    entry = "${config.package}/bin/markdownlint -c ${pkgs.writeText "markdownlint.json" (builtins.toJSON config.settings.configuration)}";
    files = "\\.md$";
  };
}

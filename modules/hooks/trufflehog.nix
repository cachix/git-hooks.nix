{ tools, lib, pkgs, ... }:
{
  config = {
    name = "trufflehog";
    description = "Detect secrets in your data.";
    package = tools.trufflehog;
    entry =
      let
        script = pkgs.writeShellScript "precommit-trufflehog" ''
          trufflehog git file://$(git rev-parse --show-toplevel) --since-commit HEAD --only-verified --fail
        '';
      in
      "${tools.trufflehog}/bin/trufflehog git file://$(git rev-parse --show-toplevel) --since-commit HEAD --only-verified --fail";
    types = [ "text" ];
  };
}
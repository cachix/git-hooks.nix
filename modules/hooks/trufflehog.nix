{ tools, lib, pkgs, config, ... }:
{
  config = {
    package = tools.trufflehog;
    entry =
      let
        script = pkgs.writeShellScript "precommit-trufflehog" ''
          set -e
          ${config.package}/bin/trufflehog --no-update git "file://$(git rev-parse --show-toplevel)" --since-commit HEAD --only-verified --fail
        '';
      in
      builtins.toString script;
    # trufflehog expects to run across the whole repo, not particular files
    pass_filenames = false;
  };
}

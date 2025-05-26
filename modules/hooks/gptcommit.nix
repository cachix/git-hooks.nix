{ config, tools, lib, pkgs, ... }:
{
  config = {
    name = "gptcommit";
    description = "Generate a commit message using GPT3.";
    package = tools.gptcommit;
    entry =
      let
        script = pkgs.writeShellScript "precommit-gptcomit" ''
          ${config.package}/bin/gptcommit prepare-commit-msg --commit-source \
            "$PRE_COMMIT_COMMIT_MSG_SOURCE" --commit-msg-file "$1"
        '';
      in
      lib.throwIf (config.package == null) "The version of Nixpkgs used by git-hooks.nix does not have the `gptcommit` package. Please use a more recent version of Nixpkgs."
        toString
        script;
    stages = [ "prepare-commit-msg" ];
  };
}

{ tools, lib, ... }:
{
  config = {
    name = "commitizen check";
    description = ''
      Check whether the current commit message follows committing rules.
    '';
    package = tools.commitizen;
    entry = "${tools.commitizen}/bin/cz check --allow-abort --commit-msg-file";
    stages = [ "commit-msg" ];
  };
}
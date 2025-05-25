{ tools, lib, ... }:
{
  config = {
    name = "annex";
    description = "Runs the git-annex hook for large file support";
    package = tools.git-annex;
    entry = "${tools.git-annex}/bin/git-annex pre-commit";
  };
}
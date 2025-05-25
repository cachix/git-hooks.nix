{ tools, lib, ... }:
{
  config = {
    name = "shellcheck";
    description = "ShellCheck is a static analysis tool for shell scripts.";
    package = tools.shellcheck;
    entry = "${tools.shellcheck}/bin/shellcheck";
    types = [ "shell" ];
  };
}
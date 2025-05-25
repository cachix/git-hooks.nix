{ tools, lib, ... }:
{
  config = {
    name = "staticcheck";
    description = "A state of the art linter for the Go programming language.";
    package = tools.go-tools;
    entry = "${tools.go-tools}/bin/staticcheck";
    types = [ "go" ];
    require_serial = true;
  };
}
{ tools, lib, ... }:
{
  config = {
    name = "check-xml";
    description = "Check syntax of XML files.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-xml";
    types = [ "xml" ];
  };
}
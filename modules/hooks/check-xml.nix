{ config, tools, lib, ... }:
{
  config = {
    name = "check-xml";
    description = "Check syntax of XML files.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-xml";
    types = [ "xml" ];
  };
}

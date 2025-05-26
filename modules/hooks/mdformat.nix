{ config, tools, lib, ... }:
{
  config = {
    name = "mdformat";
    description = "CommonMark compliant Markdown formatter.";
    package = tools.mdformat;
    entry = "${config.package}/bin/mdformat";
    types = [ "markdown" ];
  };
}

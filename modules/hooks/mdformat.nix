{ tools, lib, ... }:
{
  config = {
    name = "mdformat";
    description = "CommonMark compliant Markdown formatter.";
    package = tools.mdformat;
    entry = "${tools.mdformat}/bin/mdformat";
    types = [ "markdown" ];
  };
}
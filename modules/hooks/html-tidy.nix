{ config, tools, lib, ... }:
{
  config = {
    name = "html-tidy";
    description = "HTML linter";
    package = tools.html-tidy;
    entry = "${config.package}/bin/tidy -modify -indent -quiet";
    types = [ "html" ];
  };
}

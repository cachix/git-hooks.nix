{ config, tools, lib, ... }:
{
  config = {
    package = tools.html-tidy;
    entry = "${config.package}/bin/tidy -modify -indent -quiet";
    types = [ "html" ];
  };
}

{ tools, lib, ... }:
{
  config = {
    name = "html-tidy";
    description = "Tidy HTML files.";
    package = tools.html-tidy;
    entry = "${tools.html-tidy}/bin/tidy -modify -indent -quiet";
    types = [ "html" ];
  };
}
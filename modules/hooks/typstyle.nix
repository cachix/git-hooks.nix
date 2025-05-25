{ tools, lib, ... }:
{
  config = {
    name = "typstyle";
    description = "Format Typst files with typstyle.";
    package = tools.typstyle;
    entry = "${tools.typstyle}/bin/typstyle";
    files = "\.typ$";
  };
}
{ tools, lib, ... }:
{
  config = {
    name = "typstfmt";
    description = "Format Typst files.";
    package = tools.typstfmt;
    entry = "${tools.typstfmt}/bin/typstfmt";
    files = "\.typ$";
  };
}
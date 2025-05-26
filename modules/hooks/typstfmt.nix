{ tools, lib, config, ... }:
{
  config = {
    name = "typstfmt";
    description = "Format Typst files.";
    package = tools.typstfmt;
    entry = "${config.package}/bin/typstfmt";
    files = "\\.typ$";
  };
}

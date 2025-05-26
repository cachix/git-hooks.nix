{ tools, lib, config, ... }:
{
  config = {
    name = "purs-tidy";
    description = "Format purescript files.";
    package = tools.purs-tidy;
    entry = "${config.package}/bin/purs-tidy format-in-place";
    files = "\.purs$";
  };
}

{ tools, lib, ... }:
{
  config = {
    name = "purs-tidy";
    description = "Format PureScript files with purs-tidy.";
    package = tools.purs-tidy;
    entry = "${tools.purs-tidy}/bin/purs-tidy format-in-place";
    files = "\.purs$";
  };
}
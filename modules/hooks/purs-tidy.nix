{ tools, lib, config, ... }:
{
  config = {
    package = tools.purs-tidy;
    entry = "${config.package}/bin/purs-tidy format-in-place";
    files = "\.purs$";
  };
}

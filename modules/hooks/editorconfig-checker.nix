{ config, tools, lib, ... }:
{
  config = {
    name = "editorconfig-checker";
    description = "Verify that the files are in harmony with the `.editorconfig`.";
    package = tools.editorconfig-checker;
    entry = "${config.package}/bin/editorconfig-checker";
    types = [ "file" ];
  };
}

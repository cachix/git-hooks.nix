{ config, tools, lib, ... }:
{
  config = {
    name = "end-of-file-fixer";
    description = "Ensures that a file is either empty, or ends with a single newline.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/end-of-file-fixer";
    types = [ "text" ];
  };
}

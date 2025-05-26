{ config, tools, lib, ... }:
{
  config = {
    name = "chktex";
    description = "LaTeX semantic checker";
    types = [ "file" "tex" ];
    package = tools.chktex;
    entry = "${config.package}/bin/chktex";
  };
}

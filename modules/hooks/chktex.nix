{ tools, lib, ... }:
{
  config = {
    name = "chktex";
    description = "LaTeX semantic checker";
    types = [ "file" "tex" ];
    package = tools.chktex;
    entry = "${tools.chktex}/bin/chktex";
  };
}
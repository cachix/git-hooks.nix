{ tools, lib, ... }:
{
  config = {
    name = "ocp-indent";
    description = "A simple tool and library to indent OCaml code.";
    package = tools.ocp-indent;
    entry = "${tools.ocp-indent}/bin/ocp-indent --inplace";
    files = "\.mli?$";
  };
}